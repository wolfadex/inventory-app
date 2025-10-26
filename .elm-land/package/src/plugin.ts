import matter from "gray-matter";
import {
    existsSync,
    mkdirSync,
    readFileSync,
    readdirSync,
    writeFileSync,
} from "node:fs";
import path from "node:path";
import { spawn } from "node:child_process";
import { tmpdir } from "node:os";
import { Connect, Plugin, ViteDevServer } from "vite";
import { sep } from "node:path";
import { pathToFileURL } from "node:url";

export type Options = RouterAndOutputOptions & { extra?: ExtraOptions };

type ExtraOptions = {
    useHashBasedRouting?: boolean;
};

const inProduction = process.env.NODE_ENV === "production";

export type RouterAndOutputOptions =
    | { router: "file-based"; output: "spa" }
    | { router: "file-based"; output: "mpa"; urls: string[] }
    | { router: "file-based"; output: "js" }
    | { router: "file-based"; output: "elm" }
    | { router: "markdown"; output: "mpa" }
    | { router: "markdown"; output: "spa" }
    | { router: "markdown"; output: "js" }
    | { router: "markdown"; output: "elm" }
    | { router: "inertia"; output: "elm" }
    | { router: "manual"; routes: ManualRoutes; output: "spa" }
    | { router: "manual"; routes: ManualRoutes; output: "js" }
    | { router: "manual"; routes: ManualRoutes; output: "elm" }
    | { router: "manual"; routes: ManualRoutes; output: "mpa"; urls: string[] };

type ManualRoutes = { [url: UrlPattern]: ElmModuleName } & {
    "*": ElmModuleName;
};

export type RouterOption =
    | "manual" // User defines their own routes
    | "file-based" // Routes determined by `src/Pages/**.elm`
    | "markdown" // Routes determined by
    | "inertia";

export type OutputOption = "mpa" | "spa" | "js" | "elm";

/**
 * @example "/"
 * @example "/blog"
 * @example "/contact-us"
 * @example "/settings"
 * @example "/blog/hello-world"
 * @example "/blog/:post"
 * @example "/blog/*"
 */
export type UrlPattern = string;

/**
 * @example "Pages.Blog"
 * @example "Pages.Blog.Post_"
 * @example "Pages.HOME_"
 * @example "Pages.ERROR_"
 */
export type ElmModuleName = string;

// TODO: Allow support for 'assets/elm-land.js` too!
const inputFile = "assets/elm-land.ts";
const outputFile = "elm-land.js";

type PluginState = {
    projectRoot: string;
    server: null | ViteDevServer;
    fsCache: { [filepath: string]: string };
};

export default (options_?: Options): Plugin => {
    let options: Options = options_ || { router: "file-based", output: "spa" };

    let state: PluginState = {
        projectRoot: process.cwd(),
        server: null,
        fsCache: {},
    };

    const contentFolder = path.resolve(state.projectRoot, "content");

    const toMarkdownFile = (filepath: string): MarkdownFile | null => {
        let relativePath = path.relative(contentFolder, filepath);
        let url = toUrlFromPath(relativePath);
        let dataPage = toDataPage(url, filepath, state.projectRoot, {});
        if (dataPage) {
            return {
                url,
                frontmatter: dataPage.frontmatter,
                markdown: dataPage.markdown,
            };
        } else {
            return null;
        }
    };

    const toOtherFile = (filepath: string): string | null => {
        let relativePath = path.join(contentFolder, filepath);
        if (!existsSync(relativePath)) return null;
        return readFileSync(relativePath, "utf-8");
    };

    const getRelatedFiles = async (
        originalUrl: string,
    ): Promise<ContentFiles> => {
        let filesNeeded: FilesNeeded = { files: [], folders: [] };
        try {
            // Note: This can fail if the user's Elm code has errors
            // For that reason, we want to catch and ignore errors here, so they
            // can see a nice Elm error overlay instead of a critical Vite error
            // that prevents the page from loading at all.
            filesNeeded = await compileAndRunElmWorkerForFilesNeeded(
                { url: toUrlFromPath(originalUrl) },
                state.projectRoot,
            );
        } catch (err) {}

        let filepaths = filesNeeded.folders
            .flatMap((folder) => {
                let folderPath = path.join(
                    state.projectRoot,
                    "content",
                    folder.path,
                );
                return getAllFilesInFolder(folderPath, folder.isRecursive);
            })
            .concat(filesNeeded.files);

        let contentFiles = filepaths.reduce((obj, filepath) => {
            let file = toMarkdownFile(filepath) || toOtherFile(filepath);
            if (file) {
                obj[filepath] = file;
            }
            return obj;
        }, {} as ContentFiles);

        return contentFiles;
    };

    let plugin: Plugin = {
        name: "elm-land",

        /* @ts-ignore */
        config(config) {
            if (config === null) {
                return options;
            }

            // Prevent default index.html middleware
            config.appType = "custom";

            // Set port to 1234 if not set
            config.server = config.server || {};
            config.server.port = config.server.port || 1234;

            // Add input configuration for the entry point
            if (inProduction) {
                config.build = config.build || {};
                config.build.rollupOptions = config.build.rollupOptions || {};
                config.build.rollupOptions.input = inputFile;
                config.build.rollupOptions.output = {
                    format: "esm",
                    // Make sure filename is always "elm-land.js"
                    entryFileNames: "elm-land.js",
                    // Make sure CSS file is always "style.css"
                    assetFileNames: "style.css",
                };
            }
        },

        configResolved(config) {
            state.projectRoot = config.root;
            if (state.server) {
                console.dir(state.server.middlewares.stack);
            }
        },

        buildStart() {
            // This runs during "vite build" and "vite server", so we need to
            // check if we're in build mode
            let isInBuildMode = state.server === null;

            setupElmLandPackages(state.projectRoot, options);
            generateElmLandCode(state.projectRoot, options);

            if (isInBuildMode) {
                switch (options.output) {
                    case "spa":
                        this.emitFile({
                            type: "asset",
                            fileName: `index.html`,
                            source: fromHtmlTemplate(options, null, {
                                head: [
                                    // TODO: Get this from Main's meta
                                    {
                                        name: "link",
                                        attributes: [
                                            { key: "rel", value: "icon" },
                                            {
                                                key: "href",
                                                value: "/logo_200.png",
                                            },
                                        ],
                                        content: null,
                                    },
                                    {
                                        name: "meta",
                                        attributes: [
                                            { key: "name", value: "viewport" },
                                            {
                                                key: "content",
                                                value: "width=device-width, initial-scale=1",
                                            },
                                        ],
                                        content: null,
                                    },
                                ],
                                htmlAttributes: [],
                            }),
                        });
                        return;
                    case "mpa":
                        if (options.router === "markdown") {
                            const markdownFiles = getAllFilesInFolder(
                                contentFolder,
                                true,
                                ".md",
                            );

                            markdownFiles.forEach(async (filepath) => {
                                // Name the output file based on the relative path, accounting for the README.md
                                const relativePath = path.relative(
                                    contentFolder,
                                    filepath,
                                );
                                const fileName =
                                    relativePath === "README.md"
                                        ? "index"
                                        : relativePath.replace(/\.md$/, "");
                                const url = toUrlFromPath(relativePath);
                                const contentFiles = await getRelatedFiles(url);
                                const dataPage = toDataPage(
                                    url,
                                    filepath,
                                    state.projectRoot,
                                    contentFiles,
                                );

                                // Emit HTML file
                                this.emitFile({
                                    type: "asset",
                                    fileName: `${fileName}.html`,
                                    source: fromHtmlTemplate(
                                        options,
                                        dataPage,
                                        {
                                            head: [
                                                // TODO: Get this from page's meta
                                                {
                                                    name: "link",
                                                    attributes: [
                                                        {
                                                            key: "rel",
                                                            value: "icon",
                                                        },
                                                        {
                                                            key: "href",
                                                            value: "/logo_200.png",
                                                        },
                                                    ],
                                                    content: null,
                                                },
                                                {
                                                    name: "meta",
                                                    attributes: [
                                                        {
                                                            key: "name",
                                                            value: "viewport",
                                                        },
                                                        {
                                                            key: "content",
                                                            value: "width=device-width, initial-scale=1",
                                                        },
                                                    ],
                                                    content: null,
                                                },
                                            ],
                                            htmlAttributes: [],
                                        },
                                    ),
                                });

                                // Emit JSON file
                                this.emitFile({
                                    type: "asset",
                                    fileName: `${relativePath}.json`,
                                    source: JSON.stringify(dataPage, null, 0),
                                });
                            });
                            return;
                        }
                        break;
                }
                // TODO: Handle other router modes
                console.error(
                    "ERROR:",
                    `TODO: Implement "build" for ${options.router} in ${options.output}`,
                );
                process.exit(1);
            }
        },

        configureServer: async function (server) {
            let contentFolder = path.resolve(state.projectRoot, "content");
            let generatedFiles = toGeneratedFiles(
                state.projectRoot,
                options,
            ).filter((x) => x !== null);

            // Listen for "content/**" changes, and emit them to
            // the web browser for hot-reloading
            server.watcher.on("all", (event, filepath) => {
                let isFile =
                    event === "add" || event === "change" || event === "unlink";

                // RUN ELM CODEGEN IF FILE/FOLDER IS ADDED/RENAMED/DELETED
                if (event !== "change") {
                    let routes = determineRoutesFrom(
                        state.projectRoot,
                        options,
                    );
                    for (let file of generatedFiles) {
                        if (
                            file.foldersToWatch.some((folder) =>
                                filepath.startsWith(folder),
                            )
                        ) {
                            let content = file.toContent({ routes });

                            if (content !== state.fsCache[file.filepath]) {
                                console.log(
                                    "💾",
                                    "~/" +
                                        path.relative(
                                            state.projectRoot,
                                            file.filepath,
                                        ),
                                );
                                state.fsCache[file.filepath] = content;
                                writeFileSync(file.filepath, content, {
                                    encoding: "utf-8",
                                });
                            }
                        }
                    }
                }

                // HANDLE MARKDOWN CHANGED EVENTS
                if (options.router === "markdown") {
                    if (isFile && filepath.startsWith(contentFolder)) {
                        let relativePath = path.relative(
                            contentFolder,
                            filepath,
                        );
                        let url = toUrlFromPath(relativePath);
                        let dataPage = toDataPage(
                            url,
                            filepath,
                            state.projectRoot,
                            {},
                        );

                        server.hot.send("elm-land:markdown:changed", {
                            url,
                            data: dataPage,
                        });
                    }
                }
            });

            // The middleware to handle injecting markdown "content"
            // into HTML template during development
            let elmLandMiddleware: Connect.NextHandleFunction = async function (
                req,
                res,
                next: Connect.NextFunction,
            ) {
                try {
                    if (req.url !== "/index.html") {
                        next();
                        return;
                    }

                    let originalUrl = req.originalUrl || "/";

                    // Get the markdown file path and data for HTML rendering
                    const markdownPath = urlToMarkdownPath(
                        originalUrl,
                        state.projectRoot,
                    );

                    // Fetch the markdown data for the given URL
                    const contentFiles = await getRelatedFiles(originalUrl);

                    let dataPage = toDataPage(
                        toUrlFromPath(originalUrl),
                        markdownPath,
                        state.projectRoot,
                        contentFiles,
                    );

                    if (originalUrl.endsWith(".md.json")) {
                        // Respond with only the JSON data

                        res.setHeader(
                            "Content-Type",
                            "application/json; charset=utf-8",
                        );
                        res.end(JSON.stringify(dataPage, null, 0), "utf8");
                        return;
                    } else {
                        // Render a full HTML page including the page data

                        if (dataPage) {
                            // We need to see what head and htmlAttributes should be rendered for this
                            // page. So we need to use an Elm worker to provide that to us based on the
                            // content of the markdown file.
                            // let flags = {
                            //   url: dataPage.url,
                            //   markdown: dataPage.markdown,
                            //   frontmatter: dataPage.frontmatter
                            // }
                        }

                        // TODO: Remove this once the Elm worker is working
                        // let htmlOptions : HtmlOptions = await compileAndRunElmWorker(flags, state.projectRoot)
                        let htmlOptions: HtmlOptions = {
                            head: [
                                {
                                    name: "link",
                                    attributes: [
                                        { key: "rel", value: "icon" },
                                        { key: "href", value: "/logo_200.png" },
                                    ],
                                    content: null,
                                },
                                {
                                    name: "meta",
                                    attributes: [
                                        { key: "name", value: "viewport" },
                                        {
                                            key: "content",
                                            value: "width=device-width, initial-scale=1",
                                        },
                                    ],
                                    content: null,
                                },
                            ],
                            htmlAttributes: [],
                        };

                        // Ensure emojis render correctly
                        res.setHeader(
                            "Content-Type",
                            "text/html; charset=utf-8",
                        );
                        // Render the HTML template with the markdown content
                        res.end(
                            fromHtmlTemplate(options, dataPage, htmlOptions),
                            "utf8",
                        );
                    }
                } catch (err) {
                    next(err);
                }
            };

            // Wait until _after_ the Vite middleware has been added to the stack
            // and insert this second to last (right before the "viteErrorMiddleware")
            setTimeout(() => {
                if (server.middlewares.stack.length > 0) {
                    server.middlewares.stack.splice(
                        server.middlewares.stack.length - 1,
                        0,
                        {
                            route: "",
                            handle: htmlFallbackMiddleware(state.projectRoot),
                        },
                    );
                    server.middlewares.stack.splice(
                        server.middlewares.stack.length - 1,
                        0,
                        { route: "", handle: elmLandMiddleware },
                    );
                } else {
                    console.warn(
                        "ELM LAND:",
                        "Expected Vite middleware to be registered!",
                    );
                }
            });

            state.server = server;
        },

        // // Add a new hook to provide the virtual HTML entry
        // transformIndexHtml() {
        //   return toHtml(JSON.stringify({ markdown: '' }, null, 0))
        // }
    };

    return plugin;
};

// RENDERING HTML OUTPUT

type HtmlHeadTag = {
    name: string;
    attributes: HtmlAttribute[];
    content: string | null;
};

type HtmlAttribute = {
    key: string;
    value: string;
};

type HtmlOptions = {
    head: HtmlHeadTag[];
    htmlAttributes: HtmlAttribute[];
    noScriptTag?: string;
};

function toHtmlHeadString(head: HtmlHeadTag[]): string {
    if (head.length === 0) {
        return "";
    } else {
        return (
            head
                .map((tag) =>
                    tag.content === null
                        ? `\n  <${tag.name}${toHtmlAttributes(tag.attributes)} />`
                        : `\n  <${tag.name}${toHtmlAttributes(tag.attributes)}>${tag.content}</${tag.name}>`,
                )
                .join("") + "\n"
        );
    }
}

function toHtmlAttributes(attributes: HtmlAttribute[]): string {
    if (attributes.length === 0) {
        return "";
    } else {
        return (
            " " +
            attributes.map((attr) => `${attr.key}="${attr.value}"`).join(" ")
        );
    }
}

function fromHtmlTemplate(
    options: Options,
    dataPage: DataPage | null,
    htmlOptions: HtmlOptions,
): string {
    return `<!DOCTYPE html>
<html${toHtmlAttributes(htmlOptions.htmlAttributes)}>
<head>${toHtmlHeadString(htmlOptions.head)}${inProduction ? '  <link rel="stylesheet" href="/style.css"></link>\n' : ""}</head>
<body>${htmlOptions.noScriptTag ? `\n  ${htmlOptions.noScriptTag}` : ""}
  <div id="app" data-router="${options.router}" data-page='${JSON.stringify(dataPage, null, 0).split("'").join("&apos;")}'></div>
  <script type="module" src="/${inProduction ? outputFile : inputFile}"></script>
</body>
</html>`;
}

// URL HANDLING

function urlToMarkdownPath(url: string, projectRoot: string): string {
    // Remove any trailing slashes
    let cleanUrl = url.replace(/\/$/, "");

    // The content folder will be relative to project root
    let contentFolder = path.resolve(projectRoot, "content");

    // Handle homepage case
    if (cleanUrl === "" || cleanUrl === "/") {
        return path.resolve(contentFolder, "README.md");
    }

    // For all other paths, append .md to the URL path
    if (cleanUrl.endsWith(".md.json")) {
        return path
            .resolve(contentFolder, ...cleanUrl.split("/"))
            .slice(0, -".json".length);
    } else {
        return path.resolve(contentFolder, ...cleanUrl.split("/")) + ".md";
    }
}

function toUrlFromPath(path: string): string {
    let withExtension =
        path === "README.md" || path === "/README.md.json"
            ? "/"
            : path.replace(/\.md$/, "").replace(/\/$/, "").split(sep).join("/");

    if (!withExtension.startsWith("/")) {
        withExtension = "/" + withExtension;
    }

    return withExtension.split(".md.json").join("");
}

// FILE SYSTEM HANDLING

function getAllFilesInFolder(
    dir: string,
    isRecursive: boolean,
    extension?: string,
): string[] {
    try {
        const files = readdirSync(dir, { withFileTypes: true });
        const paths = files.map((file) => {
            const fullPath = path.resolve(dir, file.name);
            if (isRecursive && file.isDirectory()) {
                return getAllFilesInFolder(fullPath, isRecursive, extension);
            }
            if (!extension) return [fullPath];
            return file.name.endsWith(extension) ? [fullPath] : [];
        });
        return paths.flat();
    } catch (_) {
        return [];
    }
}

type DataPage = Omit<MarkdownFile, "kind"> & { content: ContentFiles };

type File = MarkdownFile | OtherFile;

type ContentFiles = { [filepath: string]: File };

type MarkdownFile = {
    url: string;
    frontmatter: unknown;
    markdown: string;
};

type OtherFile = string;

function toDataPage(
    url: string,
    filepath: string,
    projectRoot: string,
    content: ContentFiles,
): DataPage | null {
    if (!existsSync(filepath)) {
        return null;
    }
    const fileContent = readFileSync(filepath, "utf-8");
    let frontmatter = {};
    let markdown = fileContent;
    try {
        const parsed = matter(fileContent);
        frontmatter = parsed.data;
        markdown = parsed.content;
    } catch (_) {}
    const isFrontmatterAnEmptyObject = Object.keys(frontmatter).length === 0;

    return {
        url,
        frontmatter: isFrontmatterAnEmptyObject ? null : frontmatter,
        markdown,
        content,
    };
}

// RUNNING ELM TO SAFELY DECODE RAW MARKDOWN

function findElmBinary(pathToElmBinary?: string, projectRoot?: string): string {
    if (pathToElmBinary) {
        return pathToElmBinary;
    } else if (projectRoot) {
        let localNodeModules = path.resolve(
            projectRoot,
            "node_modules",
            ".bin",
            "elm",
        );
        if (existsSync(localNodeModules)) {
            return localNodeModules;
        }
    }
    return "elm";
}

async function compileElmWorker(
    elmRootFilepath: string,
    outputFilename: string,
    projectRoot: string,
    pathToElmBinary?: string,
): Promise<string> {
    // Use child_process to compile the worker
    let tempFilepath = path.resolve(
        tmpdir(),
        ".elm-land",
        "src",
        outputFilename,
    );

    // Find the filepath to the elm binary, first checking the local node_modules, then the global elm
    let elmBinary = findElmBinary(pathToElmBinary, projectRoot);

    // Wait for the worker to compile
    await new Promise((resolve, reject) => {
        let elmMakeProcess = spawn(
            elmBinary,
            ["make", elmRootFilepath, "--output", tempFilepath],
            { cwd: projectRoot, shell: true },
        );

        elmMakeProcess.on("error", (err) => {
            reject(err);
        });
        elmMakeProcess.on("close", (code) => {
            if (code === 0) {
                resolve(null);
            } else {
                reject(
                    new Error(
                        `Elm worker compilation failed with code ${code}`,
                    ),
                );
            }
        });
    });

    // return path.join(projectRoot, 'needed-files.elm.js')
    return tempFilepath;
}

type WorkerFilesNeededFlags = {
    url: string;
};

type FilesNeeded = {
    files: string[];
    folders: Folder[];
};

type Folder = {
    path: string;
    isRecursive: boolean;
};

async function compileAndRunElmWorkerForFilesNeeded(
    flags: WorkerFilesNeededFlags,
    projectRoot: string,
    pathToElmBinary?: string,
): Promise<FilesNeeded> {
    // Compile the Elm worker
    let tempFilepath = await compileElmWorker(
        path.join(
            projectRoot,
            ".elm-land",
            "src",
            "ElmLand",
            "Worker",
            "FilesNeeded.elm",
        ),
        "worker.files-needed.js",
        projectRoot,
        pathToElmBinary,
    );

    // Run the worker
    return new Promise(async (resolve, reject) => {
        let warn = console.warn;
        console.warn = () => {};
        let worker = await import(pathToFileURL(tempFilepath).href);
        console.warn = warn;
        let app = worker.default.Elm.ElmLand.Worker.FilesNeeded.init({
            flags: flags,
        });
        app.ports.success.subscribe(resolve);
        app.ports.failure.subscribe(reject);
    });
}

// VITE STUFF

/**
 * Extracted from vite@6.0.11 to ensure I'm handling
 * the HTML fallback middleware like Vite handles it.
 *
 * @param root The project root
 * @returns
 */
function htmlFallbackMiddleware(root: string): Connect.NextHandleFunction {
    return function viteHtmlFallbackMiddleware(req, _res, next) {
        if (
            !req.url ||
            // Only accept GET or HEAD
            (req.method !== "GET" && req.method !== "HEAD") || // Exclude default favicon requests
            req.url === "/favicon.ico" || // Require Accept: text/html or */*
            !(
                req.headers.accept === undefined || // equivalent to `Accept: */*`
                req.headers.accept === "" || // equivalent to `Accept: */*`
                req.headers.accept.includes("text/html") ||
                req.headers.accept.includes("*/*")
            )
        ) {
            return next();
        }
        const url = cleanUrl(req.url);
        const pathname = decodeURIComponent(url);
        if (pathname.endsWith(".html")) {
            const filePath = path.join(root, pathname);
            if (existsSync(filePath)) {
                req.url = url;
                return next();
            }
        } else if (pathname[pathname.length - 1] === "/") {
            const filePath = path.join(root, pathname, "index.html");
            if (existsSync(filePath)) {
                const newUrl = url + "index.html";
                req.url = newUrl;
                return next();
            }
        } else {
            const filePath = path.join(root, pathname + ".html");
            if (existsSync(filePath)) {
                const newUrl = url + ".html";
                req.url = newUrl;
                return next();
            }
        }

        req.url = "/index.html";
        next();
    };
}
const postfixRE = /[?#].*$/;
function cleanUrl(url: string) {
    return url.replace(postfixRE, "");
}

function generateElmLandCode(projectRoot: string, options: Options) {
    let routes = determineRoutesFrom(projectRoot, options);
    let generatedFiles = toGeneratedFiles(projectRoot, options);

    for (let file of generatedFiles) {
        let folder = path.dirname(file.filepath);
        mkdirSync(folder, { recursive: true });
        writeFileSync(file.filepath, file.toContent({ routes }), {
            encoding: "utf-8",
        });
    }
}

/**
 * Each router/output mode combination results in different packages that should
 * be available within `.elm-land/src/ElmLand/*`
 */
function setupElmLandPackages(projectRoot: string, options: Options) {
    // Packages used by every Elm Land app
    let packages = [
        "ElmLand.Effect",
        "ElmLand.Program",
        "ElmLand.Subscription",
        "ElmLand.Http",
    ];

    // Additional packages for the output mode
    switch (options.output) {
        case "elm":
        case "js":
            break;
        case "spa":
        case "mpa":
            packages = packages.concat(["ElmLand.Meta"]);
            break;
    }

    // Additional packages for the router mode
    switch (options.router) {
        case "manual":
        case "file-based":
            break;
        case "markdown":
            packages = packages.concat([
                "ElmLand.Content",
                "ElmLand.Error",
                "ElmLand.File",
                "ElmLand.Frontmatter",
                "ElmLand.Markdown",
            ]);
            break;
        case "inertia":
            packages = packages.concat(["ElmLand.Error"]);
            break;
    }

    // TODO: Clear files not included in the `packages` list
    //       and create/overwrite the ones that are present.
}

function getRoutesFromPagesFolder(projectRoot: string): ManualRoutes {
    let pagesFolder = path.join(projectRoot, "src", "Pages");

    let elmFilesInPagesFolder = getAllFilesInFolder(pagesFolder, true, ".elm");

    let pageModulePaths: string[][] = elmFilesInPagesFolder.map((filepath) =>
        path
            .relative(pagesFolder, filepath.slice(0, -".elm".length))
            .split(path.sep),
    );

    let routes: ManualRoutes = pageModulePaths.reduce(
        (routes: ManualRoutes, moduleParts: string[]) => {
            let moduleName = moduleParts.join(".");
            if (moduleName === "HOME_") {
                // Reserved "homepage" route
                routes["/"] = `Pages.HOME_`;
            } else if (moduleName === "ALL_") {
                // Reserved "catch-all" route
                routes["*"] = `Pages.ALL_`;
            } else if (moduleName === "ERROR_") {
                // Ignore the "ERROR_" page– that doesn't impact routing
                // it's just a fallback for markdown and inertia mode
            } else {
                let urlParts: string[] = moduleParts.map((part) => {
                    if (part === "ALL_") {
                        return "*";
                    } else if (part.endsWith("_")) {
                        return ":" + toKebabCase(part.slice(0, -1));
                    } else {
                        return toKebabCase(part);
                    }
                });
                routes["/" + urlParts.join("/")] = "Pages." + moduleName;
            }
            return routes;
        },
        { "*": "Pages.ALL_" },
    );

    return routes;
}

/**
 * Takes an Elm module name like "AboutUs"
 * and returns a kebab-case URL string like "about-us"
 */
function toKebabCase(str: string): string {
    return str.replace(/([a-z])([A-Z])/g, "$1-$2").toLowerCase();
}

function determineRoutesFrom(
    projectRoot: string,
    options: Options,
): ManualRoutes {
    let routes =
        options.router === "manual"
            ? options.routes
            : options.router === "inertia"
              ? { "*": "Pages.ALL_" }
              : getRoutesFromPagesFolder(projectRoot);

    return routes;
}

type GeneratedFile = {
    foldersToWatch: string[];
    filepath: string;
    toContent: (args: { routes: ManualRoutes }) => string;
};

const toMaybeGeneratedFiles = (
    projectRoot: string,
    options: Options,
): (GeneratedFile | null)[] => [
    {
        foldersToWatch: [path.join(projectRoot, "src", "Pages")],
        filepath: path.join(projectRoot, ".elm-land", "src", "Route.elm"),
        toContent: ({ routes }) =>
            toRouteModule({
                useHashBasedRouting:
                    options.extra?.useHashBasedRouting || false,
            }),
    },
    {
        foldersToWatch: [path.join(projectRoot, "src", "Pages")],
        filepath: path.join(
            projectRoot,
            ".elm-land",
            "src",
            "Route",
            "Path.elm",
        ),
        toContent: ({ routes }) =>
            toRoutePathModule({
                routes,
                useHashBasedRouting:
                    options.extra?.useHashBasedRouting || false,
            }),
    },
    {
        foldersToWatch: [path.join(projectRoot, "src", "Pages")],
        filepath: path.join(projectRoot, ".elm-land", "src", "Pages.elm"),
        toContent: ({ routes }) =>
            toPagesModule({ routes, router: options.router }),
    },
    options.router === "markdown"
        ? {
              foldersToWatch: [path.join(projectRoot, "src", "Pages")],
              filepath: path.join(
                  projectRoot,
                  ".elm-land",
                  "src",
                  "ElmLand",
                  "Worker",
                  "FilesNeeded.elm",
              ),
              toContent: ({ routes }) => toElmWorkerForFilesNeeded({ routes }),
          }
        : null,
];

const toGeneratedFiles = (
    projectRoot: string,
    options: Options,
): GeneratedFile[] =>
    toMaybeGeneratedFiles(projectRoot, options).filter((x) => x !== null);

////////////
////
//// CODE GENERATION
////
////////////

const LT = -1;
const EQ = 0;
const GT = 1;

// We start by converting each URL like so:
// "/" [ static ]
// "/about" [ static ]
// "/about/:id" [ static, dynamic ]
// "/about/:id/" [ static, dynamic ]
// "/about/:id/:name" [ static, dynamic, dynamic ]
// "/about/:id/:name/" [ static, dynamic, dynamic ]
// "/about/:id/:name/*" [ static, dynamic, dynamic, catch-all ]
let toUrlSegmentKind = (url: UrlPattern) =>
    url.split("/").map((part: string) => {
        if (part === "*") {
            return "catch-all";
        } else if (part.startsWith(":")) {
            return "dynamic";
        } else {
            return "static";
        }
    });

const bySpecificity = (
    a: [UrlPattern, ElmModuleName],
    b: [UrlPattern, ElmModuleName],
) => {
    let aUrl = a[0];
    let bUrl = b[0];

    if (!aUrl || !bUrl) {
        throw new Error(`Could not find URL for module ${a} or ${b}`);
    }

    let aParts = toUrlSegmentKind(aUrl);
    let bParts = toUrlSegmentKind(bUrl);

    // URLs that end in "/*" are catch-all
    // URL segments that start with ":" are dynamic
    // Everything else is static
    // We want to sort this list by segment length, and if there is a tie,
    // we prefer static over dynamic over catch-all

    let longerUrl = aParts.length > bParts.length ? aParts : bParts;

    for (let i = 0; i < longerUrl.length; i++) {
        if (!aParts[i]) return LT;
        if (!bParts[i]) return GT;

        if (aParts[i] !== bParts[i]) {
            if (aParts[i] === "catch-all") {
                return GT;
            } else if (bParts[i] === "catch-all") {
                return LT;
            } else if (aParts[i] === "dynamic") {
                return GT;
            } else if (bParts[i] === "dynamic") {
                return LT;
            } else {
                return EQ;
            }
        }
    }

    return aUrl < bUrl ? LT : GT;
};

// Converts "about-us" to "aboutUs"
const fromKebabCaseToCamelCase = (str: string) => {
    return str.replace(/-([a-z])/g, (match, letter) => {
        return letter.toUpperCase();
    });
};

const toRouteParamVarNames = (url: string) => {
    return url
        .split("/")
        .map((part) =>
            part === "*"
                ? "all_"
                : part.startsWith(":")
                  ? fromKebabCaseToCamelCase(part.slice(1))
                  : null,
        )
        .filter((x) => x !== null);
};

const toRouteParamType = (url: string) => {
    let paramNames = toRouteParamVarNames(url);
    if (paramNames.length === 0) {
        return "";
    }
    return (
        " { " +
        paramNames.map((name) => `${name} : ${toParamType(name)}`).join(", ") +
        " }"
    );
};

const toRouteParamMapping = (url: string) => {
    let paramNames = toRouteParamVarNames(url);
    if (paramNames.length === 0) {
        return "";
    }
    return (
        " { " + paramNames.map((name) => `${name} = ${name}`).join(", ") + " }"
    );
};

const toRouteParamDestructured = (url: string) => {
    let paramNames = toRouteParamVarNames(url);
    if (paramNames.length === 0) {
        return "";
    }
    return " { " + paramNames.map((name) => `${name}`).join(", ") + " }";
};

const toParamType = (paramName: string) => {
    return paramName === "all_" ? "List String" : "String";
};

const toUrlSegmentList = (url: string) => {
    if (url === "/") {
        return "[]";
    }

    return (
        "[ " +
        url
            .split("/")
            .filter((part) => part !== "")
            .map((part) =>
                part === "*"
                    ? 'String.join "/" all_'
                    : part.startsWith(":")
                      ? fromKebabCaseToCamelCase(part.slice(1))
                      : `"${part}"`,
            )
            .join(", ") +
        " ]"
    );
};

// Splits up the URL pattern to match a list of Elm URL segments
// "/" -> []
// "/blog" -> "blog" :: []
// "/blog/:topic/:slug" -> "blog" :: topic :: slug :: []
// "/blog/*" -> "blog" :: all_
// "/blog/:topic/:slug/*" -> "blog" :: topic :: slug :: all_
// "/*" -> all_
const toCasePattern = (url: string) => {
    if (url === "/") {
        return "[]";
    }

    let segments = url
        .split("/")
        .filter((part) => part !== "")
        .map((segment) => {
            if (segment === "*") {
                return "all_";
            } else if (segment.startsWith(":")) {
                return fromKebabCaseToCamelCase(segment.slice(1));
            } else {
                return `"${segment}"`;
            }
        });
    if (url.endsWith("*")) {
        return segments.join(" :: ");
    } else {
        return segments.join(" :: ") + " :: []";
    }
};

let dropPagesPrefix = (str: string) => str.replace(/^Pages\./, "");

const toRoutePathModule = ({
    useHashBasedRouting,
    routes,
}: {
    useHashBasedRouting: boolean;
    routes: ManualRoutes;
}) => {
    let routeEntries: [UrlPattern, ElmModuleName][] =
        Object.entries(routes).sort(bySpecificity);

    return `
-- ✨ Generated by https://elm.land 🌈 --


module Route.Path exposing
    ( Path(..)
    , fromUrl, fromString
    , href, toString
    )

{-|

@docs Path
@docs fromUrl, fromString
@docs href, toString

-}

import Html
import Html.Attributes
import Url exposing (Url)


{-| A type-safe version of the URL's path
-}
type Path
    = ${routeEntries.map(([url, casePattern]) => `${dropPagesPrefix(casePattern).split(".").join("_")}${toRouteParamType(url)}`).join("\n    | ")}


{-| Convert a URL path string to a Route.Path
-}
fromUrl : Url -> Path
fromUrl url =
    fromString url.path


{-| Convert a URL path string to a Route.Path
-}
fromString : String -> Path
fromString urlPath =
    case
        urlPath
            |> String.split "/"
            |> List.filter (String.isEmpty >> not)
    of
${routeEntries.map(([url, moduleName]) => `        ${toCasePattern(url)} ->\n            ${dropPagesPrefix(moduleName).split(".").join("_")}${toRouteParamMapping(url)}`).join("\n\n")}


{-| Convert a Route.Path into a URL path
-}
toString : Path -> String
toString path =
    case path of
${routeEntries.map(([url, moduleName]) => `        ${dropPagesPrefix(moduleName).split(".").join("_")}${toRouteParamDestructured(url)} ->\n            toUrl ${toUrlSegmentList(url)}`).join("\n\n")}


toUrl : List String -> String
toUrl segments =
    "/" ++ String.join "/" (List.filter (String.isEmpty >> not) segments)


{-| A helper function for using \`Route.Path\` with an HTML \`<a>\` tag

**Not using \`elm/html\`?** Use the \`toString\` function above to create your
own version of this function for your view library.

-}
href : Path -> Html.Attribute msg
href path =
    Html.Attributes.href (toString path)
`.trimStart();
};

const toRouteModule = ({
    useHashBasedRouting,
}: {
    useHashBasedRouting: boolean;
}) => {
    return `
-- ✨ Generated by https://elm.land 🌈 --


module Route exposing (Route, fromUrl, toString)

import Dict exposing (Dict)
import Route.Path
import Url exposing (Url)


{-| Represents the full URL for a page.

Similar to the Url type, but with type-safe parameters and
your query as a dictionary to make working with query parameters
a bit easier.

-}
type alias Route params =
    { params : params
    , path : Route.Path.Path
    , query : Dict String String
    , fragment : Maybe String
    , url : Url
    }


{-| Create a Route from a URL and parameters
-}
fromUrl : params -> Url -> Route params
fromUrl params url =
    { params = params
    , path = Route.Path.fromUrl url
    , query = createQueryDict url.query
    , fragment = url.fragment
    , url = url
    }


{-| Convert a Route into an absolute URL string.

**Note:** Works with both "Route" values and records with the path, query, and fragment
field. This is useful for creating type-safe links to other pages.

-}
toString :
    { route
        | path : Route.Path.Path
        , query : Dict String String
        , fragment : Maybe String
    }
    -> String
toString route =
    let
        queryString : String
        queryString =
            if Dict.isEmpty route.query then
                ""

            else
                "?"
                    ++ (Dict.toList route.query
                            |> List.map toQueryParamString
                            |> String.join "&"
                       )

        toQueryParamString : ( String, String ) -> String
        toQueryParamString ( key, value ) =
            if String.isEmpty value then
                Url.percentEncode key

            else
                Url.percentEncode key ++ "=" ++ Url.percentEncode value

        fragmentString : String
        fragmentString =
            case route.fragment of
                Nothing ->
                    ""

                Just fragment ->
                    "#" ++ Url.percentEncode fragment
    in
    Route.Path.toString route.path ++ queryString ++ fragmentString


createQueryDict : Maybe String -> Dict String String
createQueryDict query =
    case query of
        Nothing ->
            Dict.empty

        Just queryString ->
            let
                toPairs : String -> Maybe ( String, String )
                toPairs pair =
                    case String.split "=" pair of
                        key :: value :: [] ->
                            Maybe.map2 Tuple.pair
                                (Url.percentDecode key)
                                (Url.percentDecode value)

                        key :: [] ->
                            Maybe.map2 Tuple.pair
                                (Url.percentDecode key)
                                (Just "")

                        _ ->
                            Nothing
            in
            queryString
                |> String.split "&"
                |> List.filterMap toPairs
                |> Dict.fromList
`.trimStart();
};

// If the module is static or home, returns `()`, otherwise `params`
let hasParams = (moduleName: string, routes: ManualRoutes) => {
    let associatedUrlForValue = Object.entries(routes).find(
        ([_, value]) => value === moduleName,
    )?.[0];
    return (
        associatedUrlForValue?.includes(":") ||
        associatedUrlForValue?.includes("*")
    );
};

const toPagesModule = ({
    routes,
    router,
}: {
    routes: ManualRoutes;
    router: RouterOption;
}) => {
    let fetchesData = router === "markdown" || router === "inertia";

    let extraExposedList = fetchesData
        ? ["toDataRequest", "isOnErrorPage"]
        : undefined;

    let extraExposedValues = extraExposedList
        ? "\n    " + extraExposedList.map((x) => ", " + x).join("")
        : "";

    let extraDocTags = extraExposedList
        ? "\n@docs " + extraExposedList.join(", ") + "\n"
        : "";

    let pageModuleNamesWithoutError = Object.entries(routes)
        .sort(bySpecificity)
        .map(([_, moduleName]) => moduleName);

    let pageModuleNames = pageModuleNamesWithoutError.concat(
        router === "markdown" ? ["Pages.ERROR_"] : [],
    );

    // Convert a module name like "Pages.ALL_" to "ALL_"
    let toModuleVariant = (x: string) => x.split(".").slice(1).join("_");

    let toParamsArgFor = (moduleName: string, routes: ManualRoutes) => {
        if (hasParams(moduleName, routes)) {
            return "params";
        } else {
            return "()";
        }
    };

    let contextParams = {
        "file-based": "params",
        markdown: "data params",
        inertia: "data",
        manual: "params",
    }[router];

    let routeParams = router === "inertia" ? "" : " params";

    let contextDataField = fetchesData ? "\n    , data : data" : "";

    const modelErrorVariantDefinition = fetchesData
        ? "\n    | Model_ERROR_ ElmLand.Error.Problem Pages.ERROR_.Model"
        : "";

    const msgErrorVariantDefinition = fetchesData
        ? "\n.   | ERROR_ Pages.ERROR_.Msg"
        : "";

    const importsForMarkdownRouter =
        router === "markdown"
            ? `
import ElmLand.Content
import ElmLand.Error exposing (Problem)
import Http
import Json.Decode as Json
import Json.Encode as Encode`
            : "";

    const initDefinitions = fetchesData
        ? `
init : Json.Value -> Url -> Shared.Model -> ( Model, Effect Msg )
init json url shared =
    if json == Encode.null then
        ElmLand.Error.Problem404
            |> initErrorPage url shared

    else
        case Route.Path.fromUrl url of
${pageModuleNamesWithoutError
    .map(
        (
            modName,
        ) => `            Route.Path.${toModuleVariant(modName)}${hasParams(modName, routes) ? " params" : ""} ->
                handleInitForPage
                    { init = ${modName}.init
                    , shared = shared
                    , url = url
                    , params = ${hasParams(modName, routes) ? "params" : "()"}
                    , toModel = Model_${toModuleVariant(modName)}
                    , toMsg = ${toModuleVariant(modName)}
                    , json = json
                    , decoder = ${modName}.decoder
                    }`,
    )
    .join("\n\n")}


handleInitForPage :
    { init : Context ${contextParams} -> ( pageModel, Effect pageMsg )
    , params : params
    , url : Url
    , shared : Shared.Model
    , toModel : pageModel -> Model
    , toMsg : pageMsg -> Msg
    , json : Json.Value
    , decoder : ElmLand.Content.Decoder data
    }
    -> ( Model, Effect Msg )
handleInitForPage props =
    case ElmLand.Content.decode props.decoder props.json of
        Ok data ->
            let
                ( model, effect ) =
                    props.init
                        { route = Route.fromUrl props.params props.url
                        , shared = props.shared
                        , data = data
                        }
            in
            ( props.toModel model
            , effect
                |> Effect.map props.toMsg
            )

        Err reason ->
            ElmLand.Error.Problem500 reason
                |> initErrorPage props.url props.shared


initErrorPage : Url -> Shared.Model -> ElmLand.Error.Problem -> ( Model, Effect Msg )
initErrorPage url shared problem =
    let
        ( pageModel, pageEffect ) =
            Pages.ERROR_.init
                { data = problem
                , route = Route.fromUrl () url
                , shared = shared
                }
    in
    ( Model_ERROR_ problem pageModel
    , Effect.map ERROR_ pageEffect
    )`.trimStart()
        : `
init : Url -> Shared.Model -> ( Model, Effect Msg )
init url shared =
    case Route.Path.fromUrl url of
${pageModuleNamesWithoutError
    .map(
        (
            modName,
        ) => `        Route.Path.${toModuleVariant(modName)}${hasParams(modName, routes) ? " params" : ""} ->
            handleInitForPage
                { init = ${modName}.init
                , shared = shared
                , url = url
                , params = ${hasParams(modName, routes) ? "params" : "()"}
                , toModel = Model_${toModuleVariant(modName)}
                , toMsg = ${toModuleVariant(modName)}
                }`,
    )
    .join("\n\n")}


handleInitForPage :
    { init : Context params -> ( pageModel, Effect pageMsg )
    , params : params
    , url : Url
    , shared : Shared.Model
    , toModel : pageModel -> Model
    , toMsg : pageMsg -> Msg
    }
    -> ( Model, Effect Msg )
handleInitForPage props =
    let
        ( model, effect ) =
            props.init
                { route = Route.fromUrl props.params props.url
                , shared = props.shared
                }
    in
    ( props.toModel model
    , effect
        |> Effect.map props.toMsg
    )`.trimStart();

    const updateDefininitions = fetchesData
        ? `
update :
    Json.Value
    -> Url
    -> Shared.Model
    -> Msg
    -> Model
    -> ( Model, Effect Msg )
update data url shared msg model =
    case ( Route.Path.fromUrl url, msg, model ) of
        ( _, ERROR_ pageMsg, Model_ERROR_ problem pageModel ) ->
            handleUpdateForErrorPage
                { url = url
                , shared = shared
                , problem = problem
                , pageModel = pageModel
                , pageMsg = pageMsg
                }

${pageModuleNamesWithoutError
    .map(
        (
            modName,
        ) => `        ( Route.Path.${toModuleVariant(modName)}${hasParams(modName, routes) ? " params" : ""}, ${toModuleVariant(modName)} pageMsg, Model_${toModuleVariant(modName)} pageModel ) ->
            handleUpdateForPage
                { update = ${modName}.update
                , url = url
                , shared = shared
                , toModel = Model_${toModuleVariant(modName)}
                , toMsg = ${toModuleVariant(modName)}
                , params = ${toParamsArgFor(modName, routes)}
                , pageModel = pageModel
                , pageMsg = pageMsg
                , data = data
                , decoder = ${modName}.decoder
                }`,
    )
    .join("\n\n")}

        _ ->
            ( model
            , Effect.none
            )


handleUpdateForPage :
    { update : Context ${contextParams} -> pageMsg -> pageModel -> ( pageModel, Effect pageMsg )
    , url : Url
    , shared : Shared.Model
    , toModel : pageModel -> Model
    , toMsg : pageMsg -> Msg
    , params : params
    , pageModel : pageModel
    , pageMsg : pageMsg
    , data : Json.Value
    , decoder : ElmLand.Content.Decoder data
    }
    -> ( Model, Effect Msg )
handleUpdateForPage props =
    case ElmLand.Content.decode props.decoder props.data of
        Ok data ->
            let
                ( model, effect ) =
                    props.update
                        { route = Route.fromUrl props.params props.url
                        , shared = props.shared
                        , data = data
                        }
                        props.pageMsg
                        props.pageModel
            in
            ( props.toModel model
            , effect
                |> Effect.map props.toMsg
            )

        Err problem ->
            ElmLand.Error.Problem500 problem
                |> initErrorPage props.url props.shared


handleUpdateForErrorPage :
    { problem : ElmLand.Error.Problem
    , url : Url
    , shared : Shared.Model
    , pageMsg : Pages.ERROR_.Msg
    , pageModel : Pages.ERROR_.Model
    }
    -> ( Model, Effect Msg )
handleUpdateForErrorPage props =
    let
        ( model, effect ) =
            Pages.ERROR_.update
                { route = Route.fromUrl () props.url
                , shared = props.shared
                , data = props.problem
                }
                props.pageMsg
                props.pageModel
    in
    ( Model_ERROR_ props.problem model
    , effect
        |> Effect.map ERROR_
    )`.trimStart()
        : `
update :
    Url
    -> Shared.Model
    -> Msg
    -> Model
    -> ( Model, Effect Msg )
update url shared msg model =
    case ( Route.Path.fromUrl url, msg, model ) of
${pageModuleNamesWithoutError
    .map(
        (
            modName,
        ) => `        ( Route.Path.${toModuleVariant(modName)}${hasParams(modName, routes) ? " params" : ""}, ${toModuleVariant(modName)} pageMsg, Model_${toModuleVariant(modName)} pageModel ) ->
            handleUpdateForPage
                { update = ${modName}.update
                , url = url
                , shared = shared
                , toModel = Model_${toModuleVariant(modName)}
                , toMsg = ${toModuleVariant(modName)}
                , params = ${toParamsArgFor(modName, routes)}
                , pageModel = pageModel
                , pageMsg = pageMsg
                }`,
    )
    .join("\n\n")}${
              pageModuleNamesWithoutError.length > 1
                  ? `

        _ ->
            ( model
            , Effect.none
            )`
                  : ""
          }


handleUpdateForPage :
    { update : Context ${contextParams} -> pageMsg -> pageModel -> ( pageModel, Effect pageMsg )
    , url : Url
    , shared : Shared.Model
    , toModel : pageModel -> Model
    , toMsg : pageMsg -> Msg
    , params : params
    , pageModel : pageModel
    , pageMsg : pageMsg
    }
    -> ( Model, Effect Msg )
handleUpdateForPage props =
    let
        ( model, effect ) =
            props.update
                { route = Route.fromUrl props.params props.url
                , shared = props.shared
                }
                props.pageMsg
                props.pageModel
    in
    ( props.toModel model
    , effect
        |> Effect.map props.toMsg
    )`.trimStart();

    const subscriptionsDefinitions = fetchesData
        ? `
subscriptions : Json.Value -> Url -> Shared.Model -> Model -> Subscription Msg
subscriptions data url shared model =
    case ( model, Route.Path.fromUrl url ) of
${pageModuleNamesWithoutError
    .map(
        (
            modName,
        ) => `        ( Model_${toModuleVariant(modName)} pageModel, Route.Path.${toModuleVariant(modName)}${hasParams(modName, routes) ? " params" : ""} ) ->
            handleSubscriptionsForPage
                { subscriptions = ${modName}.subscriptions
                , url = url
                , params = ${toParamsArgFor(modName, routes)}
                , shared = shared
                , toMsg = ${toModuleVariant(modName)}
                , pageModel = pageModel
                , data = data
                , decoder = ${modName}.decoder
                }

        ( Model_${toModuleVariant(modName)} _, _ ) ->
            Subscription.none`,
    )
    .join("\n\n")}

        ( Model_ERROR_ problem pageModel, _ ) ->
            Pages.ERROR_.subscriptions
                { route = Route.fromUrl () url
                , shared = shared
                , data = problem
                }
                pageModel
                |> Subscription.map ERROR_


handleSubscriptionsForPage :
    { subscriptions : Context ${contextParams} -> pageModel -> Subscription pageMsg
    , url : Url
    , params : params
    , shared : Shared.Model
    , toMsg : pageMsg -> Msg
    , pageModel : pageModel
    , data : Json.Value
    , decoder : ElmLand.Content.Decoder data
    }
    -> Subscription Msg
handleSubscriptionsForPage props =
    case ElmLand.Content.decode props.decoder props.data of
        Ok data ->
            props.subscriptions
                { route = Route.fromUrl props.params props.url
                , shared = props.shared
                , data = data
                }
                props.pageModel
                |> Subscription.map props.toMsg

        Err _ ->
            Subscription.none`.trimStart()
        : `
subscriptions : Url -> Shared.Model -> Model -> Subscription Msg
subscriptions url shared model =
    case ( model, Route.Path.fromUrl url ) of
${pageModuleNamesWithoutError
    .map(
        (
            modName,
        ) => `        ( Model_${toModuleVariant(modName)} pageModel, Route.Path.${toModuleVariant(modName)}${hasParams(modName, routes) ? " params" : ""} ) ->
            handleSubscriptionsForPage
                { subscriptions = ${modName}.subscriptions
                , url = url
                , params = ${toParamsArgFor(modName, routes)}
                , shared = shared
                , toMsg = ${toModuleVariant(modName)}
                , pageModel = pageModel
                }${
                    pageModuleNamesWithoutError.length > 1
                        ? `

        ( Model_${toModuleVariant(modName)} _, _ ) ->
            Subscription.none`
                        : ""
                }`,
    )
    .join("\n\n")}


handleSubscriptionsForPage :
    { subscriptions : Context ${contextParams} -> pageModel -> Subscription pageMsg
    , url : Url
    , params : params
    , shared : Shared.Model
    , toMsg : pageMsg -> Msg
    , pageModel : pageModel
    }
    -> Subscription Msg
handleSubscriptionsForPage props =
    props.subscriptions
        { route = Route.fromUrl props.params props.url
        , shared = props.shared
        }
        props.pageModel
        |> Subscription.map props.toMsg`.trimStart();

    const viewDefinitions = fetchesData
        ? `
view : Json.Value -> Url -> Shared.Model -> Model -> Browser.Document Msg
view data url shared model =
    case ( model, Route.Path.fromUrl url ) of
        ( Model_ERROR_ problem pageModel, _ ) ->
            Pages.ERROR_.view { data = problem, route = Route.fromUrl () url, shared = shared } pageModel
                |> documentMap ERROR_

${pageModuleNamesWithoutError
    .map(
        (
            modName,
        ) => `        ( Model_${toModuleVariant(modName)} pageModel, Route.Path.${toModuleVariant(modName)}${hasParams(modName, routes) ? " params" : ""} ) ->
            handleViewForPage
                { view = ${modName}.view
                , url = url
                , params = ${toParamsArgFor(modName, routes)}
                , shared = shared
                , toMsg = ${toModuleVariant(modName)}
                , pageModel = pageModel
                , data = data
                , decoder = ${modName}.decoder
                }

        ( Model_${toModuleVariant(modName)} _, _ ) ->
            "The route doesn't match the current page."
                |> viewErrorPage url shared`,
    )
    .join("\n\n")}


handleViewForPage :
    { view : Context ${contextParams} -> pageModel -> Browser.Document pageMsg
    , url : Url
    , params : params
    , shared : Shared.Model
    , toMsg : pageMsg -> Msg
    , pageModel : pageModel
    , data : Json.Value
    , decoder : ElmLand.Content.Decoder data
    }
    -> Browser.Document Msg
handleViewForPage props =
    case ElmLand.Content.decode props.decoder props.data of
        Ok data ->
            props.view
                { route = Route.fromUrl props.params props.url
                , shared = props.shared
                , data = data
                }
                props.pageModel
                |> documentMap props.toMsg

        Err problem ->
            problem
                |> viewErrorPage props.url props.shared


viewErrorPage : Url -> Shared.Model -> String -> Browser.Document Msg
viewErrorPage url shared problem =
    let
        context =
            { route = Route.fromUrl () url
            , shared = shared
            , data = ElmLand.Error.Problem500 problem
            }
    in
    -- Better than showing nothing!
    Pages.ERROR_.view context (Tuple.first (Pages.ERROR_.init context))
        |> documentMap ERROR_`.trimStart()
        : `
view : Url -> Shared.Model -> Model -> Browser.Document Msg
view url shared model =
    case ( model, Route.Path.fromUrl url ) of
${pageModuleNamesWithoutError
    .map(
        (
            modName,
        ) => `        ( Model_${toModuleVariant(modName)} pageModel, Route.Path.${toModuleVariant(modName)}${hasParams(modName, routes) ? " params" : ""} ) ->
            handleViewForPage
                { view = ${modName}.view
                , url = url
                , params = ${toParamsArgFor(modName, routes)}
                , shared = shared
                , toMsg = ${toModuleVariant(modName)}
                , pageModel = pageModel
                }${
                    pageModuleNamesWithoutError.length > 1
                        ? `

        ( Model_${toModuleVariant(modName)} _, _ ) ->
            "The route doesn't match the current page."
                |> viewErrorPage url shared`
                        : ""
                }`,
    )
    .join("\n\n")}


handleViewForPage :
    { view : Context ${contextParams} -> pageModel -> Browser.Document pageMsg
    , url : Url
    , params : params
    , shared : Shared.Model
    , toMsg : pageMsg -> Msg
    , pageModel : pageModel
    }
    -> Browser.Document Msg
handleViewForPage props =
    props.view
        { route = Route.fromUrl props.params props.url
        , shared = props.shared
        }
        props.pageModel
        |> documentMap props.toMsg


viewErrorPage : Url -> Shared.Model -> String -> Browser.Document msg
viewErrorPage url shared problem =
    { title = "ERROR"
    , body = [ Html.text problem ]
    }`.trimStart();

    const dataFetchingDefinitions = fetchesData
        ? `\n\n\ntoDataRequest : String -> (Result Http.Error Json.Value -> msg) -> Url -> Cmd msg
toDataRequest tracker toMsg url =
    Http.request
        { method = "GET"
        , headers = []
        , url =
            if url.path == "/" then
                "/README.md.json"

            else
                url.path ++ ".md.json"
        , body = Http.emptyBody
        , expect = Http.expectJson toMsg Json.value
        , tracker = Just tracker
        , timeout = Nothing
        }


{-| When markdown content changes during development, this
helps us know whether we should reload the page to show
or clear out any errors.
-}
isOnErrorPage : Model -> Bool
isOnErrorPage model =
    case model of
        Model_ERROR_ _ _ ->
            True

        _ ->
            False`
        : "";

    return `
-- ✨ Generated by https://elm.land 🌈 --


module Pages exposing
    ( Model, Msg
    , init, update, subscriptions, view${extraExposedValues}
    )

{-| Connects all pages together, and renders the
right one based on the current URL

@docs Model, Msg
@docs init, update, subscriptions, view
${extraDocTags}
-}

import Browser
import Effect exposing (Effect)
import Html
${pageModuleNames
    .map((x) => "import " + x)
    .sort()
    .join("\n")}
import Route exposing (Route)
import Route.Path
import Shared
import Subscription exposing (Subscription)
import Url exposing (Url)${importsForMarkdownRouter}


type alias Context ${contextParams} =
    { route : Route${routeParams}
    , shared : Shared.Model${contextDataField}
    }



-- INIT


type Model
    = ${pageModuleNamesWithoutError.map((modName) => `Model_${toModuleVariant(modName)} ${modName}.Model`).join("\n    | ")}${modelErrorVariantDefinition}


${initDefinitions}



-- UPDATE


type Msg
    = ${pageModuleNamesWithoutError.map((modName) => `${toModuleVariant(modName)} ${modName}.Msg`).join("\n    | ")}${msgErrorVariantDefinition}


${updateDefininitions}



-- SUBSCRIPTIONS


${subscriptionsDefinitions}



-- VIEW


${viewDefinitions}



-- UTILS${dataFetchingDefinitions}


documentMap : (msg1 -> msg2) -> Browser.Document msg1 -> Browser.Document msg2
documentMap fn doc =
    { title = doc.title
    , body = List.map (Html.map fn) doc.body
    }
`.trimStart();
};

const toElmWorkerForFilesNeeded = ({ routes }: { routes: ManualRoutes }) => {
    let pageModuleNamesWithoutError = Object.values(routes);

    return `port module ElmLand.Worker.FilesNeeded exposing (main)

import ElmLand.Content as Content
import Json.Encode
${pageModuleNamesWithoutError.map((modName) => `import ${modName}`).join("\n")}
import Platform
import Route.Path



-- PORTS


port success : Json.Encode.Value -> Cmd msg


port failure : String -> Cmd msg


type alias Flags =
    { url : String
    }


type alias Model =
    ()


type alias Msg =
    ()


main : Platform.Program Flags Model Msg
main =
    Platform.worker
        { init = determineFilesNeeded
        , update = \\_ model -> ( model, Cmd.none )
        , subscriptions = \\_ -> Sub.none
        }


determineFilesNeeded : Flags -> ( Model, Cmd Msg )
determineFilesNeeded flags =
    ( ()
    , case toFilesNeeded flags of
        Ok filesNeeded ->
            filesNeeded
                |> encodeFilesNeeded
                |> success

        Err reason ->
            failure reason
    )


toFilesNeeded : Flags -> Result String Content.FilesNeeded
toFilesNeeded flags =
    case Route.Path.fromString flags.url of
${pageModuleNamesWithoutError
    .map(
        (
            modName,
        ) => `        Route.Path.${dropPagesPrefix(modName).split(".").join("_")}${hasParams(modName, routes) ? " _" : ""} ->
            ${modName}.decoder
                |> Content.toFilesNeeded
                |> Ok`,
    )
    .join("\n\n")}



-- FILES NEEDED


encodeFilesNeeded : Content.FilesNeeded -> Json.Encode.Value
encodeFilesNeeded filesNeeded =
    Json.Encode.object
        [ ( "files"
          , Json.Encode.list Json.Encode.string filesNeeded.files
          )
        , ( "folders"
          , Json.Encode.list encodeFolder filesNeeded.folders
          )
        ]


encodeFolder : { path : String, isRecursive : Bool } -> Json.Encode.Value
encodeFolder data =
    Json.Encode.object
        [ ( "path", Json.Encode.string data.path )
        , ( "isRecursive", Json.Encode.bool data.isRecursive )
        ]
`.trimStart();
};
