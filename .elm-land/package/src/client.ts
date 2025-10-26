export type Options<flags>= {
  root: Elm.Root<{ data: unknown, user?: flags }>
  flags?: flags
  confirmNavigationMessage?: string
  nodeId?: string
}

type ElmLandPorts = {
  elmLand__setShouldPreventNavigation: Elm.OutgoingPort<boolean>
  elmLand__showConfirmNavigationDialog: Elm.OutgoingPort<null>
  elmLand__onUserConfirmedNavigation: Elm.IncomingPort<boolean>
  // Ports only used by Elm Land during development
  elmLand__onMarkdownChanged: Elm.IncomingPort<{ filepath: string, markdown: string }>
}

type RouterOption
  = 'file-based'
  | 'markdown'
  | 'inertia'

export function init<ports extends {}, flags>(
  options: Options<flags>
) : Elm.App<ports> {
  let nodeId = options.nodeId || 'app'

  // Grab HTML element
  let node = document.getElementById(nodeId)
  if (!node)
    throw new Error(`Elm Land: I could not find an element with id="${nodeId}" when initializing your program.`)

  // Detect the "router" mode from that element
  let dataRouter : string | null = node.getAttribute('data-router')
  let router : RouterOption | undefined
    = (dataRouter === 'markdown') ? 'markdown'
    : (dataRouter === 'inertia') ? 'inertia'
    : (dataRouter == 'file-based') ? 'file-based'
    : undefined
  if (router === undefined)
    throw new Error (`Elm Land: I expected the "data-router" attribute to be: "markdown", "inertia", or "file-based". I found "${dataRouter}" instead!`)

  // Look for an optional "data-page" attribute with initial page data
  let data = JSON.parse(node.getAttribute('data-page') || 'null')

  let app : Elm.App<ElmLandPorts & ports> = options.root.init({
    node: node,
    flags: { data: data, user: options.flags }
  })

  if (Object.keys(app).length === 0) {
    if (import.meta.env.DEV) {
      node.innerHTML = `
        <div style="position: fixed; z-index: 1; inset: 0; display: flex; flex-direction: column; gap: 1rem; align-items: center; justify-content: center; background: white; color: black; padding: 2rem; text-align: center; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;">
          <img src="https://next.elm.land/logo_200.png" alt="Elm Land Logo" style="width: 4rem; height: 4rem;" />
          <h1 style="margin: 0; font-size: 2em; font-weight: 700;">Error Found on Startup</h1>
          <p style="margin: 0; opacity: 0.75;">Please refresh this page.</p>
        </div>
      `
      // This is normal and will happen when your Elm app fails to compile during development
      throw new Error('"The compiler found a problem, please see the browser overlay for details."')
    } else {
      // Your Elm app is failing to compile in production 
      // (Elm Land's build system is designed to prevent this, likely caused by a custom build step)
      throw new Error('"Something went wrong when trying to start the app."')
    }
  }

  if (import.meta.hot) {
    if (router === 'markdown') {
      // Listen for changes to Markdown files at the current route
      import.meta.hot.on('elm-land:markdown:changed', (urlAndData) => {
        console.log('elm-land:markdown:changed', urlAndData)
        app.ports?.elmLand__onMarkdownChanged.send(urlAndData)
      })
    }
  }

  // Preventing navigation when there is unsaved data
  //
  // 1. Handles clicking links within the page
  app.ports?.elmLand__showConfirmNavigationDialog.subscribe(function () {
    let answer = window.confirm(
      options.confirmNavigationMessage
        || 'There may be unsaved changes. Are you sure you want to leave this page?'
    )

    if (answer) {
      app.ports?.elmLand__onUserConfirmedNavigation.send(true)
    }
  })
  //
  // 2. Handles hitting refresh or editing the URL
  let shouldPreventNavigation = false
  app.ports?.elmLand__setShouldPreventNavigation.subscribe(function (newValue) {
    shouldPreventNavigation = newValue
  })
  window.addEventListener('beforeunload', (event) => {
    if (shouldPreventNavigation) {
      // Show the confirmation dialog
      event.preventDefault()
      event.returnValue = 'true'
      return 'true'
    }
  })

  /**
   * Remove all the built-in "elmLand__" ports to make the
   * returned Elm app meet expectations
   */
  let ports : Elm.App<ports>['ports'] =
    Object.keys(app.ports || {}).reduce((obj, key) => {
      if (obj && !key.startsWith('elmLand__')) {
        obj[key] = (app.ports as any)[key]
      }
      return obj
    }, {} as any)


  // Return the app so the user can work with ports
  return {
    ports
  }
}


export default { init }