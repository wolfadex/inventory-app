// -- (function(scope){
// -- 'use strict';

function F(arity, fun, wrapper) {
  wrapper.a = arity;
  wrapper.f = fun;
  return wrapper;
}

function F2(fun) {
  return F(2, fun, function(a) { return function(b) { return fun(a,b); }; })
}
function F3(fun) {
  return F(3, fun, function(a) {
    return function(b) { return function(c) { return fun(a, b, c); }; };
  });
}
function F4(fun) {
  return F(4, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return fun(a, b, c, d); }; }; };
  });
}
function F5(fun) {
  return F(5, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return fun(a, b, c, d, e); }; }; }; };
  });
}
function F6(fun) {
  return F(6, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return fun(a, b, c, d, e, f); }; }; }; }; };
  });
}
function F7(fun) {
  return F(7, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return fun(a, b, c, d, e, f, g); }; }; }; }; }; };
  });
}
function F8(fun) {
  return F(8, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) {
    return fun(a, b, c, d, e, f, g, h); }; }; }; }; }; }; };
  });
}
function F9(fun) {
  return F(9, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) { return function(i) {
    return fun(a, b, c, d, e, f, g, h, i); }; }; }; }; }; }; }; };
  });
}

function A2(fun, a, b) {
  return fun.a === 2 ? fun.f(a, b) : fun(a)(b);
}
function A3(fun, a, b, c) {
  return fun.a === 3 ? fun.f(a, b, c) : fun(a)(b)(c);
}
function A4(fun, a, b, c, d) {
  return fun.a === 4 ? fun.f(a, b, c, d) : fun(a)(b)(c)(d);
}
function A5(fun, a, b, c, d, e) {
  return fun.a === 5 ? fun.f(a, b, c, d, e) : fun(a)(b)(c)(d)(e);
}
function A6(fun, a, b, c, d, e, f) {
  return fun.a === 6 ? fun.f(a, b, c, d, e, f) : fun(a)(b)(c)(d)(e)(f);
}
function A7(fun, a, b, c, d, e, f, g) {
  return fun.a === 7 ? fun.f(a, b, c, d, e, f, g) : fun(a)(b)(c)(d)(e)(f)(g);
}
function A8(fun, a, b, c, d, e, f, g, h) {
  return fun.a === 8 ? fun.f(a, b, c, d, e, f, g, h) : fun(a)(b)(c)(d)(e)(f)(g)(h);
}
function A9(fun, a, b, c, d, e, f, g, h, i) {
  return fun.a === 9 ? fun.f(a, b, c, d, e, f, g, h, i) : fun(a)(b)(c)(d)(e)(f)(g)(h)(i);
}

console.warn('Compiled in DEV mode. Follow the advice at https://elm-lang.org/0.19.1/optimize for better performance and smaller assets.');


var _JsArray_empty = [];

function _JsArray_singleton(value)
{
    return [value];
}

function _JsArray_length(array)
{
    return array.length;
}

var _JsArray_initialize = F3(function(size, offset, func)
{
    var result = new Array(size);

    for (var i = 0; i < size; i++)
    {
        result[i] = func(offset + i);
    }

    return result;
});

var _JsArray_initializeFromList = F2(function (max, ls)
{
    var result = new Array(max);

    for (var i = 0; i < max && ls.b; i++)
    {
        result[i] = ls.a;
        ls = ls.b;
    }

    result.length = i;
    return _Utils_Tuple2(result, ls);
});

var _JsArray_unsafeGet = F2(function(index, array)
{
    return array[index];
});

var _JsArray_unsafeSet = F3(function(index, value, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[index] = value;
    return result;
});

var _JsArray_push = F2(function(value, array)
{
    var length = array.length;
    var result = new Array(length + 1);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[length] = value;
    return result;
});

var _JsArray_foldl = F3(function(func, acc, array)
{
    var length = array.length;

    for (var i = 0; i < length; i++)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_foldr = F3(function(func, acc, array)
{
    for (var i = array.length - 1; i >= 0; i--)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_map = F2(function(func, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = func(array[i]);
    }

    return result;
});

var _JsArray_indexedMap = F3(function(func, offset, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = A2(func, offset + i, array[i]);
    }

    return result;
});

var _JsArray_slice = F3(function(from, to, array)
{
    return array.slice(from, to);
});

var _JsArray_appendN = F3(function(n, dest, source)
{
    var destLen = dest.length;
    var itemsToCopy = n - destLen;

    if (itemsToCopy > source.length)
    {
        itemsToCopy = source.length;
    }

    var size = destLen + itemsToCopy;
    var result = new Array(size);

    for (var i = 0; i < destLen; i++)
    {
        result[i] = dest[i];
    }

    for (var i = 0; i < itemsToCopy; i++)
    {
        result[i + destLen] = source[i];
    }

    return result;
});



// LOG

var _Debug_log_UNUSED = F2(function(tag, value)
{
	return value;
});

var _Debug_log = F2(function(tag, value)
{
	console.log(tag + ': ' + _Debug_toString(value));
	return value;
});


// TODOS

function _Debug_todo(moduleName, region)
{
	return function(message) {
		_Debug_crash(8, moduleName, region, message);
	};
}

function _Debug_todoCase(moduleName, region, value)
{
	return function(message) {
		_Debug_crash(9, moduleName, region, value, message);
	};
}


// TO STRING

function _Debug_toString_UNUSED(value)
{
	return '<internals>';
}

function _Debug_toString(value)
{
	return _Debug_toAnsiString(false, value);
}

function _Debug_toAnsiString(ansi, value)
{
	if (typeof value === 'function')
	{
		return _Debug_internalColor(ansi, '<function>');
	}

	if (typeof value === 'boolean')
	{
		return _Debug_ctorColor(ansi, value ? 'True' : 'False');
	}

	if (typeof value === 'number')
	{
		return _Debug_numberColor(ansi, value + '');
	}

	if (value instanceof String)
	{
		return _Debug_charColor(ansi, "'" + _Debug_addSlashes(value, true) + "'");
	}

	if (typeof value === 'string')
	{
		return _Debug_stringColor(ansi, '"' + _Debug_addSlashes(value, false) + '"');
	}

	if (typeof value === 'object' && '$' in value)
	{
		var tag = value.$;

		if (typeof tag === 'number')
		{
			return _Debug_internalColor(ansi, '<internals>');
		}

		if (tag[0] === '#')
		{
			var output = [];
			for (var k in value)
			{
				if (k === '$') continue;
				output.push(_Debug_toAnsiString(ansi, value[k]));
			}
			return '(' + output.join(',') + ')';
		}

		if (tag === 'Set_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Set')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Set$toList(value));
		}

		if (tag === 'RBNode_elm_builtin' || tag === 'RBEmpty_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Dict')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Dict$toList(value));
		}

		if (tag === 'Array_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Array')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Array$toList(value));
		}

		if (tag === '::' || tag === '[]')
		{
			var output = '[';

			value.b && (output += _Debug_toAnsiString(ansi, value.a), value = value.b)

			for (; value.b; value = value.b) // WHILE_CONS
			{
				output += ',' + _Debug_toAnsiString(ansi, value.a);
			}
			return output + ']';
		}

		var output = '';
		for (var i in value)
		{
			if (i === '$') continue;
			var str = _Debug_toAnsiString(ansi, value[i]);
			var c0 = str[0];
			var parenless = c0 === '{' || c0 === '(' || c0 === '[' || c0 === '<' || c0 === '"' || str.indexOf(' ') < 0;
			output += ' ' + (parenless ? str : '(' + str + ')');
		}
		return _Debug_ctorColor(ansi, tag) + output;
	}

	if (typeof DataView === 'function' && value instanceof DataView)
	{
		return _Debug_stringColor(ansi, '<' + value.byteLength + ' bytes>');
	}

	if (typeof File !== 'undefined' && value instanceof File)
	{
		return _Debug_internalColor(ansi, '<' + value.name + '>');
	}

	if (typeof value === 'object')
	{
		var output = [];
		for (var key in value)
		{
			var field = key[0] === '_' ? key.slice(1) : key;
			output.push(_Debug_fadeColor(ansi, field) + ' = ' + _Debug_toAnsiString(ansi, value[key]));
		}
		if (output.length === 0)
		{
			return '{}';
		}
		return '{ ' + output.join(', ') + ' }';
	}

	return _Debug_internalColor(ansi, '<internals>');
}

function _Debug_addSlashes(str, isChar)
{
	var s = str
		.replace(/\\/g, '\\\\')
		.replace(/\n/g, '\\n')
		.replace(/\t/g, '\\t')
		.replace(/\r/g, '\\r')
		.replace(/\v/g, '\\v')
		.replace(/\0/g, '\\0');

	if (isChar)
	{
		return s.replace(/\'/g, '\\\'');
	}
	else
	{
		return s.replace(/\"/g, '\\"');
	}
}

function _Debug_ctorColor(ansi, string)
{
	return ansi ? '\x1b[96m' + string + '\x1b[0m' : string;
}

function _Debug_numberColor(ansi, string)
{
	return ansi ? '\x1b[95m' + string + '\x1b[0m' : string;
}

function _Debug_stringColor(ansi, string)
{
	return ansi ? '\x1b[93m' + string + '\x1b[0m' : string;
}

function _Debug_charColor(ansi, string)
{
	return ansi ? '\x1b[92m' + string + '\x1b[0m' : string;
}

function _Debug_fadeColor(ansi, string)
{
	return ansi ? '\x1b[37m' + string + '\x1b[0m' : string;
}

function _Debug_internalColor(ansi, string)
{
	return ansi ? '\x1b[36m' + string + '\x1b[0m' : string;
}

function _Debug_toHexDigit(n)
{
	return String.fromCharCode(n < 10 ? 48 + n : 55 + n);
}


// CRASH


function _Debug_crash_UNUSED(identifier)
{
	throw new Error('https://github.com/elm/core/blob/1.0.0/hints/' + identifier + '.md');
}


function _Debug_crash(identifier, fact1, fact2, fact3, fact4)
{
	switch(identifier)
	{
		case 0:
			throw new Error('What node should I take over? In JavaScript I need something like:\n\n    Elm.Main.init({\n        node: document.getElementById("elm-node")\n    })\n\nYou need to do this with any Browser.sandbox or Browser.element program.');

		case 1:
			throw new Error('Browser.application programs cannot handle URLs like this:\n\n    ' + document.location.href + '\n\nWhat is the root? The root of your file system? Try looking at this program with `elm reactor` or some other server.');

		case 2:
			var jsonErrorString = fact1;
			throw new Error('Problem with the flags given to your Elm program on initialization.\n\n' + jsonErrorString);

		case 3:
			var portName = fact1;
			throw new Error('There can only be one port named `' + portName + '`, but your program has multiple.');

		case 4:
			var portName = fact1;
			var problem = fact2;
			throw new Error('Trying to send an unexpected type of value through port `' + portName + '`:\n' + problem);

		case 5:
			throw new Error('Trying to use `(==)` on functions.\nThere is no way to know if functions are "the same" in the Elm sense.\nRead more about this at https://package.elm-lang.org/packages/elm/core/latest/Basics#== which describes why it is this way and what the better version will look like.');

		case 6:
			var moduleName = fact1;
			throw new Error('Your page is loading multiple Elm scripts with a module named ' + moduleName + '. Maybe a duplicate script is getting loaded accidentally? If not, rename one of them so I know which is which!');

		case 8:
			var moduleName = fact1;
			var region = fact2;
			var message = fact3;
			throw new Error('TODO in module `' + moduleName + '` ' + _Debug_regionToString(region) + '\n\n' + message);

		case 9:
			var moduleName = fact1;
			var region = fact2;
			var value = fact3;
			var message = fact4;
			throw new Error(
				'TODO in module `' + moduleName + '` from the `case` expression '
				+ _Debug_regionToString(region) + '\n\nIt received the following value:\n\n    '
				+ _Debug_toString(value).replace('\n', '\n    ')
				+ '\n\nBut the branch that handles it says:\n\n    ' + message.replace('\n', '\n    ')
			);

		case 10:
			throw new Error('Bug in https://github.com/elm/virtual-dom/issues');

		case 11:
			throw new Error('Cannot perform mod 0. Division by zero error.');
	}
}

function _Debug_regionToString(region)
{
	if (region.start.line === region.end.line)
	{
		return 'on line ' + region.start.line;
	}
	return 'on lines ' + region.start.line + ' through ' + region.end.line;
}



// EQUALITY

function _Utils_eq(x, y)
{
	for (
		var pair, stack = [], isEqual = _Utils_eqHelp(x, y, 0, stack);
		isEqual && (pair = stack.pop());
		isEqual = _Utils_eqHelp(pair.a, pair.b, 0, stack)
		)
	{}

	return isEqual;
}

function _Utils_eqHelp(x, y, depth, stack)
{
	if (x === y)
	{
		return true;
	}

	if (typeof x !== 'object' || x === null || y === null)
	{
		typeof x === 'function' && _Debug_crash(5);
		return false;
	}

	if (depth > 100)
	{
		stack.push(_Utils_Tuple2(x,y));
		return true;
	}

	/**/
	if (x.$ === 'Set_elm_builtin')
	{
		x = $elm$core$Set$toList(x);
		y = $elm$core$Set$toList(y);
	}
	if (x.$ === 'RBNode_elm_builtin' || x.$ === 'RBEmpty_elm_builtin')
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	/**_UNUSED/
	if (x.$ < 0)
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	for (var key in x)
	{
		if (!_Utils_eqHelp(x[key], y[key], depth + 1, stack))
		{
			return false;
		}
	}
	return true;
}

var _Utils_equal = F2(_Utils_eq);
var _Utils_notEqual = F2(function(a, b) { return !_Utils_eq(a,b); });



// COMPARISONS

// Code in Generate/JavaScript.hs, Basics.js, and List.js depends on
// the particular integer values assigned to LT, EQ, and GT.

function _Utils_cmp(x, y, ord)
{
	if (typeof x !== 'object')
	{
		return x === y ? /*EQ*/ 0 : x < y ? /*LT*/ -1 : /*GT*/ 1;
	}

	/**/
	if (x instanceof String)
	{
		var a = x.valueOf();
		var b = y.valueOf();
		return a === b ? 0 : a < b ? -1 : 1;
	}
	//*/

	/**_UNUSED/
	if (typeof x.$ === 'undefined')
	//*/
	/**/
	if (x.$[0] === '#')
	//*/
	{
		return (ord = _Utils_cmp(x.a, y.a))
			? ord
			: (ord = _Utils_cmp(x.b, y.b))
				? ord
				: _Utils_cmp(x.c, y.c);
	}

	// traverse conses until end of a list or a mismatch
	for (; x.b && y.b && !(ord = _Utils_cmp(x.a, y.a)); x = x.b, y = y.b) {} // WHILE_CONSES
	return ord || (x.b ? /*GT*/ 1 : y.b ? /*LT*/ -1 : /*EQ*/ 0);
}

var _Utils_lt = F2(function(a, b) { return _Utils_cmp(a, b) < 0; });
var _Utils_le = F2(function(a, b) { return _Utils_cmp(a, b) < 1; });
var _Utils_gt = F2(function(a, b) { return _Utils_cmp(a, b) > 0; });
var _Utils_ge = F2(function(a, b) { return _Utils_cmp(a, b) >= 0; });

var _Utils_compare = F2(function(x, y)
{
	var n = _Utils_cmp(x, y);
	return n < 0 ? $elm$core$Basics$LT : n ? $elm$core$Basics$GT : $elm$core$Basics$EQ;
});


// COMMON VALUES

var _Utils_Tuple0_UNUSED = 0;
var _Utils_Tuple0 = { $: '#0' };

function _Utils_Tuple2_UNUSED(a, b) { return { a: a, b: b }; }
function _Utils_Tuple2(a, b) { return { $: '#2', a: a, b: b }; }

function _Utils_Tuple3_UNUSED(a, b, c) { return { a: a, b: b, c: c }; }
function _Utils_Tuple3(a, b, c) { return { $: '#3', a: a, b: b, c: c }; }

function _Utils_chr_UNUSED(c) { return c; }
function _Utils_chr(c) { return new String(c); }


// RECORDS

function _Utils_update(oldRecord, updatedFields)
{
	var newRecord = {};

	for (var key in oldRecord)
	{
		newRecord[key] = oldRecord[key];
	}

	for (var key in updatedFields)
	{
		newRecord[key] = updatedFields[key];
	}

	return newRecord;
}


// APPEND

var _Utils_append = F2(_Utils_ap);

function _Utils_ap(xs, ys)
{
	// append Strings
	if (typeof xs === 'string')
	{
		return xs + ys;
	}

	// append Lists
	if (!xs.b)
	{
		return ys;
	}
	var root = _List_Cons(xs.a, ys);
	xs = xs.b
	for (var curr = root; xs.b; xs = xs.b) // WHILE_CONS
	{
		curr = curr.b = _List_Cons(xs.a, ys);
	}
	return root;
}



var _List_Nil_UNUSED = { $: 0 };
var _List_Nil = { $: '[]' };

function _List_Cons_UNUSED(hd, tl) { return { $: 1, a: hd, b: tl }; }
function _List_Cons(hd, tl) { return { $: '::', a: hd, b: tl }; }


var _List_cons = F2(_List_Cons);

function _List_fromArray(arr)
{
	var out = _List_Nil;
	for (var i = arr.length; i--; )
	{
		out = _List_Cons(arr[i], out);
	}
	return out;
}

function _List_toArray(xs)
{
	for (var out = []; xs.b; xs = xs.b) // WHILE_CONS
	{
		out.push(xs.a);
	}
	return out;
}

var _List_map2 = F3(function(f, xs, ys)
{
	for (var arr = []; xs.b && ys.b; xs = xs.b, ys = ys.b) // WHILE_CONSES
	{
		arr.push(A2(f, xs.a, ys.a));
	}
	return _List_fromArray(arr);
});

var _List_map3 = F4(function(f, xs, ys, zs)
{
	for (var arr = []; xs.b && ys.b && zs.b; xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A3(f, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map4 = F5(function(f, ws, xs, ys, zs)
{
	for (var arr = []; ws.b && xs.b && ys.b && zs.b; ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A4(f, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map5 = F6(function(f, vs, ws, xs, ys, zs)
{
	for (var arr = []; vs.b && ws.b && xs.b && ys.b && zs.b; vs = vs.b, ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A5(f, vs.a, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_sortBy = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		return _Utils_cmp(f(a), f(b));
	}));
});

var _List_sortWith = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		var ord = A2(f, a, b);
		return ord === $elm$core$Basics$EQ ? 0 : ord === $elm$core$Basics$LT ? -1 : 1;
	}));
});



// TASKS

function _Scheduler_succeed(value)
{
	return {
		$: 0,
		a: value
	};
}

function _Scheduler_fail(error)
{
	return {
		$: 1,
		a: error
	};
}

function _Scheduler_binding(callback)
{
	return {
		$: 2,
		b: callback,
		c: null
	};
}

var _Scheduler_andThen = F2(function(callback, task)
{
	return {
		$: 3,
		b: callback,
		d: task
	};
});

var _Scheduler_onError = F2(function(callback, task)
{
	return {
		$: 4,
		b: callback,
		d: task
	};
});

function _Scheduler_receive(callback)
{
	return {
		$: 5,
		b: callback
	};
}


// PROCESSES

var _Scheduler_guid = 0;

function _Scheduler_rawSpawn(task)
{
	var proc = {
		$: 0,
		e: _Scheduler_guid++,
		f: task,
		g: null,
		h: []
	};

	_Scheduler_enqueue(proc);

	return proc;
}

function _Scheduler_spawn(task)
{
	return _Scheduler_binding(function(callback) {
		callback(_Scheduler_succeed(_Scheduler_rawSpawn(task)));
	});
}

function _Scheduler_rawSend(proc, msg)
{
	proc.h.push(msg);
	_Scheduler_enqueue(proc);
}

var _Scheduler_send = F2(function(proc, msg)
{
	return _Scheduler_binding(function(callback) {
		_Scheduler_rawSend(proc, msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});

function _Scheduler_kill(proc)
{
	return _Scheduler_binding(function(callback) {
		var task = proc.f;
		if (task.$ === 2 && task.c)
		{
			task.c();
		}

		proc.f = null;

		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
}


/* STEP PROCESSES

type alias Process =
  { $ : tag
  , id : unique_id
  , root : Task
  , stack : null | { $: SUCCEED | FAIL, a: callback, b: stack }
  , mailbox : [msg]
  }

*/


var _Scheduler_working = false;
var _Scheduler_queue = [];


function _Scheduler_enqueue(proc)
{
	_Scheduler_queue.push(proc);
	if (_Scheduler_working)
	{
		return;
	}
	_Scheduler_working = true;
	while (proc = _Scheduler_queue.shift())
	{
		_Scheduler_step(proc);
	}
	_Scheduler_working = false;
}


function _Scheduler_step(proc)
{
	while (proc.f)
	{
		var rootTag = proc.f.$;
		if (rootTag === 0 || rootTag === 1)
		{
			while (proc.g && proc.g.$ !== rootTag)
			{
				proc.g = proc.g.i;
			}
			if (!proc.g)
			{
				return;
			}
			proc.f = proc.g.b(proc.f.a);
			proc.g = proc.g.i;
		}
		else if (rootTag === 2)
		{
			proc.f.c = proc.f.b(function(newRoot) {
				proc.f = newRoot;
				_Scheduler_enqueue(proc);
			});
			return;
		}
		else if (rootTag === 5)
		{
			if (proc.h.length === 0)
			{
				return;
			}
			proc.f = proc.f.b(proc.h.shift());
		}
		else // if (rootTag === 3 || rootTag === 4)
		{
			proc.g = {
				$: rootTag === 3 ? 0 : 1,
				b: proc.f.b,
				i: proc.g
			};
			proc.f = proc.f.d;
		}
	}
}


// BYTES

function _Bytes_width(bytes)
{
	return bytes.byteLength;
}

var _Bytes_getHostEndianness = F2(function(le, be)
{
	return _Scheduler_binding(function(callback)
	{
		callback(_Scheduler_succeed(new Uint8Array(new Uint32Array([1]))[0] === 1 ? le : be));
	});
});


// ENCODERS

function _Bytes_encode(encoder)
{
	var mutableBytes = new DataView(new ArrayBuffer($elm$bytes$Bytes$Encode$getWidth(encoder)));
	$elm$bytes$Bytes$Encode$write(encoder)(mutableBytes)(0);
	return mutableBytes;
}


// SIGNED INTEGERS

var _Bytes_write_i8  = F3(function(mb, i, n) { mb.setInt8(i, n); return i + 1; });
var _Bytes_write_i16 = F4(function(mb, i, n, isLE) { mb.setInt16(i, n, isLE); return i + 2; });
var _Bytes_write_i32 = F4(function(mb, i, n, isLE) { mb.setInt32(i, n, isLE); return i + 4; });


// UNSIGNED INTEGERS

var _Bytes_write_u8  = F3(function(mb, i, n) { mb.setUint8(i, n); return i + 1 ;});
var _Bytes_write_u16 = F4(function(mb, i, n, isLE) { mb.setUint16(i, n, isLE); return i + 2; });
var _Bytes_write_u32 = F4(function(mb, i, n, isLE) { mb.setUint32(i, n, isLE); return i + 4; });


// FLOATS

var _Bytes_write_f32 = F4(function(mb, i, n, isLE) { mb.setFloat32(i, n, isLE); return i + 4; });
var _Bytes_write_f64 = F4(function(mb, i, n, isLE) { mb.setFloat64(i, n, isLE); return i + 8; });


// BYTES

var _Bytes_write_bytes = F3(function(mb, offset, bytes)
{
	for (var i = 0, len = bytes.byteLength, limit = len - 4; i <= limit; i += 4)
	{
		mb.setUint32(offset + i, bytes.getUint32(i));
	}
	for (; i < len; i++)
	{
		mb.setUint8(offset + i, bytes.getUint8(i));
	}
	return offset + len;
});


// STRINGS

function _Bytes_getStringWidth(string)
{
	for (var width = 0, i = 0; i < string.length; i++)
	{
		var code = string.charCodeAt(i);
		width +=
			(code < 0x80) ? 1 :
			(code < 0x800) ? 2 :
			(code < 0xD800 || 0xDBFF < code) ? 3 : (i++, 4);
	}
	return width;
}

var _Bytes_write_string = F3(function(mb, offset, string)
{
	for (var i = 0; i < string.length; i++)
	{
		var code = string.charCodeAt(i);
		offset +=
			(code < 0x80)
				? (mb.setUint8(offset, code)
				, 1
				)
				:
			(code < 0x800)
				? (mb.setUint16(offset, 0xC080 /* 0b1100000010000000 */
					| (code >>> 6 & 0x1F /* 0b00011111 */) << 8
					| code & 0x3F /* 0b00111111 */)
				, 2
				)
				:
			(code < 0xD800 || 0xDBFF < code)
				? (mb.setUint16(offset, 0xE080 /* 0b1110000010000000 */
					| (code >>> 12 & 0xF /* 0b00001111 */) << 8
					| code >>> 6 & 0x3F /* 0b00111111 */)
				, mb.setUint8(offset + 2, 0x80 /* 0b10000000 */
					| code & 0x3F /* 0b00111111 */)
				, 3
				)
				:
			(code = (code - 0xD800) * 0x400 + string.charCodeAt(++i) - 0xDC00 + 0x10000
			, mb.setUint32(offset, 0xF0808080 /* 0b11110000100000001000000010000000 */
				| (code >>> 18 & 0x7 /* 0b00000111 */) << 24
				| (code >>> 12 & 0x3F /* 0b00111111 */) << 16
				| (code >>> 6 & 0x3F /* 0b00111111 */) << 8
				| code & 0x3F /* 0b00111111 */)
			, 4
			);
	}
	return offset;
});


// DECODER

var _Bytes_decode = F2(function(decoder, bytes)
{
	try {
		return $elm$core$Maybe$Just(A2(decoder, bytes, 0).b);
	} catch(e) {
		return $elm$core$Maybe$Nothing;
	}
});

var _Bytes_read_i8  = F2(function(      bytes, offset) { return _Utils_Tuple2(offset + 1, bytes.getInt8(offset)); });
var _Bytes_read_i16 = F3(function(isLE, bytes, offset) { return _Utils_Tuple2(offset + 2, bytes.getInt16(offset, isLE)); });
var _Bytes_read_i32 = F3(function(isLE, bytes, offset) { return _Utils_Tuple2(offset + 4, bytes.getInt32(offset, isLE)); });
var _Bytes_read_u8  = F2(function(      bytes, offset) { return _Utils_Tuple2(offset + 1, bytes.getUint8(offset)); });
var _Bytes_read_u16 = F3(function(isLE, bytes, offset) { return _Utils_Tuple2(offset + 2, bytes.getUint16(offset, isLE)); });
var _Bytes_read_u32 = F3(function(isLE, bytes, offset) { return _Utils_Tuple2(offset + 4, bytes.getUint32(offset, isLE)); });
var _Bytes_read_f32 = F3(function(isLE, bytes, offset) { return _Utils_Tuple2(offset + 4, bytes.getFloat32(offset, isLE)); });
var _Bytes_read_f64 = F3(function(isLE, bytes, offset) { return _Utils_Tuple2(offset + 8, bytes.getFloat64(offset, isLE)); });

var _Bytes_read_bytes = F3(function(len, bytes, offset)
{
	return _Utils_Tuple2(offset + len, new DataView(bytes.buffer, bytes.byteOffset + offset, len));
});

var _Bytes_read_string = F3(function(len, bytes, offset)
{
	var string = '';
	var end = offset + len;
	for (; offset < end;)
	{
		var byte = bytes.getUint8(offset++);
		string +=
			(byte < 128)
				? String.fromCharCode(byte)
				:
			((byte & 0xE0 /* 0b11100000 */) === 0xC0 /* 0b11000000 */)
				? String.fromCharCode((byte & 0x1F /* 0b00011111 */) << 6 | bytes.getUint8(offset++) & 0x3F /* 0b00111111 */)
				:
			((byte & 0xF0 /* 0b11110000 */) === 0xE0 /* 0b11100000 */)
				? String.fromCharCode(
					(byte & 0xF /* 0b00001111 */) << 12
					| (bytes.getUint8(offset++) & 0x3F /* 0b00111111 */) << 6
					| bytes.getUint8(offset++) & 0x3F /* 0b00111111 */
				)
				:
				(byte =
					((byte & 0x7 /* 0b00000111 */) << 18
						| (bytes.getUint8(offset++) & 0x3F /* 0b00111111 */) << 12
						| (bytes.getUint8(offset++) & 0x3F /* 0b00111111 */) << 6
						| bytes.getUint8(offset++) & 0x3F /* 0b00111111 */
					) - 0x10000
				, String.fromCharCode(Math.floor(byte / 0x400) + 0xD800, byte % 0x400 + 0xDC00)
				);
	}
	return _Utils_Tuple2(offset, string);
});

var _Bytes_decodeFailure = F2(function() { throw 0; });



// MATH

var _Basics_add = F2(function(a, b) { return a + b; });
var _Basics_sub = F2(function(a, b) { return a - b; });
var _Basics_mul = F2(function(a, b) { return a * b; });
var _Basics_fdiv = F2(function(a, b) { return a / b; });
var _Basics_idiv = F2(function(a, b) { return (a / b) | 0; });
var _Basics_pow = F2(Math.pow);

var _Basics_remainderBy = F2(function(b, a) { return a % b; });

// https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/divmodnote-letter.pdf
var _Basics_modBy = F2(function(modulus, x)
{
	var answer = x % modulus;
	return modulus === 0
		? _Debug_crash(11)
		:
	((answer > 0 && modulus < 0) || (answer < 0 && modulus > 0))
		? answer + modulus
		: answer;
});


// TRIGONOMETRY

var _Basics_pi = Math.PI;
var _Basics_e = Math.E;
var _Basics_cos = Math.cos;
var _Basics_sin = Math.sin;
var _Basics_tan = Math.tan;
var _Basics_acos = Math.acos;
var _Basics_asin = Math.asin;
var _Basics_atan = Math.atan;
var _Basics_atan2 = F2(Math.atan2);


// MORE MATH

function _Basics_toFloat(x) { return x; }
function _Basics_truncate(n) { return n | 0; }
function _Basics_isInfinite(n) { return n === Infinity || n === -Infinity; }

var _Basics_ceiling = Math.ceil;
var _Basics_floor = Math.floor;
var _Basics_round = Math.round;
var _Basics_sqrt = Math.sqrt;
var _Basics_log = Math.log;
var _Basics_isNaN = isNaN;


// BOOLEANS

function _Basics_not(bool) { return !bool; }
var _Basics_and = F2(function(a, b) { return a && b; });
var _Basics_or  = F2(function(a, b) { return a || b; });
var _Basics_xor = F2(function(a, b) { return a !== b; });



var _Bitwise_and = F2(function(a, b)
{
	return a & b;
});

var _Bitwise_or = F2(function(a, b)
{
	return a | b;
});

var _Bitwise_xor = F2(function(a, b)
{
	return a ^ b;
});

function _Bitwise_complement(a)
{
	return ~a;
};

var _Bitwise_shiftLeftBy = F2(function(offset, a)
{
	return a << offset;
});

var _Bitwise_shiftRightBy = F2(function(offset, a)
{
	return a >> offset;
});

var _Bitwise_shiftRightZfBy = F2(function(offset, a)
{
	return a >>> offset;
});



var _String_cons = F2(function(chr, str)
{
	return chr + str;
});

function _String_uncons(string)
{
	var word = string.charCodeAt(0);
	return !isNaN(word)
		? $elm$core$Maybe$Just(
			0xD800 <= word && word <= 0xDBFF
				? _Utils_Tuple2(_Utils_chr(string[0] + string[1]), string.slice(2))
				: _Utils_Tuple2(_Utils_chr(string[0]), string.slice(1))
		)
		: $elm$core$Maybe$Nothing;
}

var _String_append = F2(function(a, b)
{
	return a + b;
});

function _String_length(str)
{
	return str.length;
}

var _String_map = F2(function(func, string)
{
	var len = string.length;
	var array = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = string.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			array[i] = func(_Utils_chr(string[i] + string[i+1]));
			i += 2;
			continue;
		}
		array[i] = func(_Utils_chr(string[i]));
		i++;
	}
	return array.join('');
});

var _String_filter = F2(function(isGood, str)
{
	var arr = [];
	var len = str.length;
	var i = 0;
	while (i < len)
	{
		var char = str[i];
		var word = str.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += str[i];
			i++;
		}

		if (isGood(_Utils_chr(char)))
		{
			arr.push(char);
		}
	}
	return arr.join('');
});

function _String_reverse(str)
{
	var len = str.length;
	var arr = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = str.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			arr[len - i] = str[i + 1];
			i++;
			arr[len - i] = str[i - 1];
			i++;
		}
		else
		{
			arr[len - i] = str[i];
			i++;
		}
	}
	return arr.join('');
}

var _String_foldl = F3(function(func, state, string)
{
	var len = string.length;
	var i = 0;
	while (i < len)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += string[i];
			i++;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_foldr = F3(function(func, state, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_split = F2(function(sep, str)
{
	return str.split(sep);
});

var _String_join = F2(function(sep, strs)
{
	return strs.join(sep);
});

var _String_slice = F3(function(start, end, str) {
	return str.slice(start, end);
});

function _String_trim(str)
{
	return str.trim();
}

function _String_trimLeft(str)
{
	return str.replace(/^\s+/, '');
}

function _String_trimRight(str)
{
	return str.replace(/\s+$/, '');
}

function _String_words(str)
{
	return _List_fromArray(str.trim().split(/\s+/g));
}

function _String_lines(str)
{
	return _List_fromArray(str.split(/\r\n|\r|\n/g));
}

function _String_toUpper(str)
{
	return str.toUpperCase();
}

function _String_toLower(str)
{
	return str.toLowerCase();
}

var _String_any = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (isGood(_Utils_chr(char)))
		{
			return true;
		}
	}
	return false;
});

var _String_all = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (!isGood(_Utils_chr(char)))
		{
			return false;
		}
	}
	return true;
});

var _String_contains = F2(function(sub, str)
{
	return str.indexOf(sub) > -1;
});

var _String_startsWith = F2(function(sub, str)
{
	return str.indexOf(sub) === 0;
});

var _String_endsWith = F2(function(sub, str)
{
	return str.length >= sub.length &&
		str.lastIndexOf(sub) === str.length - sub.length;
});

var _String_indexes = F2(function(sub, str)
{
	var subLen = sub.length;

	if (subLen < 1)
	{
		return _List_Nil;
	}

	var i = 0;
	var is = [];

	while ((i = str.indexOf(sub, i)) > -1)
	{
		is.push(i);
		i = i + subLen;
	}

	return _List_fromArray(is);
});


// TO STRING

function _String_fromNumber(number)
{
	return number + '';
}


// INT CONVERSIONS

function _String_toInt(str)
{
	var total = 0;
	var code0 = str.charCodeAt(0);
	var start = code0 == 0x2B /* + */ || code0 == 0x2D /* - */ ? 1 : 0;

	for (var i = start; i < str.length; ++i)
	{
		var code = str.charCodeAt(i);
		if (code < 0x30 || 0x39 < code)
		{
			return $elm$core$Maybe$Nothing;
		}
		total = 10 * total + code - 0x30;
	}

	return i == start
		? $elm$core$Maybe$Nothing
		: $elm$core$Maybe$Just(code0 == 0x2D ? -total : total);
}


// FLOAT CONVERSIONS

function _String_toFloat(s)
{
	// check if it is a hex, octal, or binary number
	if (s.length === 0 || /[\sxbo]/.test(s))
	{
		return $elm$core$Maybe$Nothing;
	}
	var n = +s;
	// faster isNaN check
	return n === n ? $elm$core$Maybe$Just(n) : $elm$core$Maybe$Nothing;
}

function _String_fromList(chars)
{
	return _List_toArray(chars).join('');
}




function _Char_toCode(char)
{
	var code = char.charCodeAt(0);
	if (0xD800 <= code && code <= 0xDBFF)
	{
		return (code - 0xD800) * 0x400 + char.charCodeAt(1) - 0xDC00 + 0x10000
	}
	return code;
}

function _Char_fromCode(code)
{
	return _Utils_chr(
		(code < 0 || 0x10FFFF < code)
			? '\uFFFD'
			:
		(code <= 0xFFFF)
			? String.fromCharCode(code)
			:
		(code -= 0x10000,
			String.fromCharCode(Math.floor(code / 0x400) + 0xD800, code % 0x400 + 0xDC00)
		)
	);
}

function _Char_toUpper(char)
{
	return _Utils_chr(char.toUpperCase());
}

function _Char_toLower(char)
{
	return _Utils_chr(char.toLowerCase());
}

function _Char_toLocaleUpper(char)
{
	return _Utils_chr(char.toLocaleUpperCase());
}

function _Char_toLocaleLower(char)
{
	return _Utils_chr(char.toLocaleLowerCase());
}


// CREATE

var _Regex_never = /.^/;

var _Regex_fromStringWith = F2(function(options, string)
{
	var flags = 'g';
	if (options.multiline) { flags += 'm'; }
	if (options.caseInsensitive) { flags += 'i'; }

	try
	{
		return $elm$core$Maybe$Just(new RegExp(string, flags));
	}
	catch(error)
	{
		return $elm$core$Maybe$Nothing;
	}
});


// USE

var _Regex_contains = F2(function(re, string)
{
	return string.match(re) !== null;
});


var _Regex_findAtMost = F3(function(n, re, str)
{
	var out = [];
	var number = 0;
	var string = str;
	var lastIndex = re.lastIndex;
	var prevLastIndex = -1;
	var result;
	while (number++ < n && (result = re.exec(string)))
	{
		if (prevLastIndex == re.lastIndex) break;
		var i = result.length - 1;
		var subs = new Array(i);
		while (i > 0)
		{
			var submatch = result[i];
			subs[--i] = submatch
				? $elm$core$Maybe$Just(submatch)
				: $elm$core$Maybe$Nothing;
		}
		out.push(A4($elm$regex$Regex$Match, result[0], result.index, number, _List_fromArray(subs)));
		prevLastIndex = re.lastIndex;
	}
	re.lastIndex = lastIndex;
	return _List_fromArray(out);
});


var _Regex_replaceAtMost = F4(function(n, re, replacer, string)
{
	var count = 0;
	function jsReplacer(match)
	{
		if (count++ >= n)
		{
			return match;
		}
		var i = arguments.length - 3;
		var submatches = new Array(i);
		while (i > 0)
		{
			var submatch = arguments[i];
			submatches[--i] = submatch
				? $elm$core$Maybe$Just(submatch)
				: $elm$core$Maybe$Nothing;
		}
		return replacer(A4($elm$regex$Regex$Match, match, arguments[arguments.length - 2], count, _List_fromArray(submatches)));
	}
	return string.replace(re, jsReplacer);
});

var _Regex_splitAtMost = F3(function(n, re, str)
{
	var string = str;
	var out = [];
	var start = re.lastIndex;
	var restoreLastIndex = re.lastIndex;
	while (n--)
	{
		var result = re.exec(string);
		if (!result) break;
		out.push(string.slice(start, result.index));
		start = re.lastIndex;
	}
	out.push(string.slice(start));
	re.lastIndex = restoreLastIndex;
	return _List_fromArray(out);
});

var _Regex_infinity = Infinity;



/**/
function _Json_errorToString(error)
{
	return $elm$json$Json$Decode$errorToString(error);
}
//*/


// CORE DECODERS

function _Json_succeed(msg)
{
	return {
		$: 0,
		a: msg
	};
}

function _Json_fail(msg)
{
	return {
		$: 1,
		a: msg
	};
}

function _Json_decodePrim(decoder)
{
	return { $: 2, b: decoder };
}

var _Json_decodeInt = _Json_decodePrim(function(value) {
	return (typeof value !== 'number')
		? _Json_expecting('an INT', value)
		:
	(-2147483647 < value && value < 2147483647 && (value | 0) === value)
		? $elm$core$Result$Ok(value)
		:
	(isFinite(value) && !(value % 1))
		? $elm$core$Result$Ok(value)
		: _Json_expecting('an INT', value);
});

var _Json_decodeBool = _Json_decodePrim(function(value) {
	return (typeof value === 'boolean')
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a BOOL', value);
});

var _Json_decodeFloat = _Json_decodePrim(function(value) {
	return (typeof value === 'number')
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a FLOAT', value);
});

var _Json_decodeValue = _Json_decodePrim(function(value) {
	return $elm$core$Result$Ok(_Json_wrap(value));
});

var _Json_decodeString = _Json_decodePrim(function(value) {
	return (typeof value === 'string')
		? $elm$core$Result$Ok(value)
		: (value instanceof String)
			? $elm$core$Result$Ok(value + '')
			: _Json_expecting('a STRING', value);
});

function _Json_decodeList(decoder) { return { $: 3, b: decoder }; }
function _Json_decodeArray(decoder) { return { $: 4, b: decoder }; }

function _Json_decodeNull(value) { return { $: 5, c: value }; }

var _Json_decodeField = F2(function(field, decoder)
{
	return {
		$: 6,
		d: field,
		b: decoder
	};
});

var _Json_decodeIndex = F2(function(index, decoder)
{
	return {
		$: 7,
		e: index,
		b: decoder
	};
});

function _Json_decodeKeyValuePairs(decoder)
{
	return {
		$: 8,
		b: decoder
	};
}

function _Json_mapMany(f, decoders)
{
	return {
		$: 9,
		f: f,
		g: decoders
	};
}

var _Json_andThen = F2(function(callback, decoder)
{
	return {
		$: 10,
		b: decoder,
		h: callback
	};
});

function _Json_oneOf(decoders)
{
	return {
		$: 11,
		g: decoders
	};
}


// DECODING OBJECTS

var _Json_map1 = F2(function(f, d1)
{
	return _Json_mapMany(f, [d1]);
});

var _Json_map2 = F3(function(f, d1, d2)
{
	return _Json_mapMany(f, [d1, d2]);
});

var _Json_map3 = F4(function(f, d1, d2, d3)
{
	return _Json_mapMany(f, [d1, d2, d3]);
});

var _Json_map4 = F5(function(f, d1, d2, d3, d4)
{
	return _Json_mapMany(f, [d1, d2, d3, d4]);
});

var _Json_map5 = F6(function(f, d1, d2, d3, d4, d5)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5]);
});

var _Json_map6 = F7(function(f, d1, d2, d3, d4, d5, d6)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6]);
});

var _Json_map7 = F8(function(f, d1, d2, d3, d4, d5, d6, d7)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7]);
});

var _Json_map8 = F9(function(f, d1, d2, d3, d4, d5, d6, d7, d8)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7, d8]);
});


// DECODE

var _Json_runOnString = F2(function(decoder, string)
{
	try
	{
		var value = JSON.parse(string);
		return _Json_runHelp(decoder, value);
	}
	catch (e)
	{
		return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'This is not valid JSON! ' + e.message, _Json_wrap(string)));
	}
});

var _Json_run = F2(function(decoder, value)
{
	return _Json_runHelp(decoder, _Json_unwrap(value));
});

function _Json_runHelp(decoder, value)
{
	switch (decoder.$)
	{
		case 2:
			return decoder.b(value);

		case 5:
			return (value === null)
				? $elm$core$Result$Ok(decoder.c)
				: _Json_expecting('null', value);

		case 3:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('a LIST', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _List_fromArray);

		case 4:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _Json_toElmArray);

		case 6:
			var field = decoder.d;
			if (typeof value !== 'object' || value === null || !(field in value))
			{
				return _Json_expecting('an OBJECT with a field named `' + field + '`', value);
			}
			var result = _Json_runHelp(decoder.b, value[field]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, field, result.a));

		case 7:
			var index = decoder.e;
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			if (index >= value.length)
			{
				return _Json_expecting('a LONGER array. Need index ' + index + ' but only see ' + value.length + ' entries', value);
			}
			var result = _Json_runHelp(decoder.b, value[index]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, index, result.a));

		case 8:
			if (typeof value !== 'object' || value === null || _Json_isArray(value))
			{
				return _Json_expecting('an OBJECT', value);
			}

			var keyValuePairs = _List_Nil;
			// TODO test perf of Object.keys and switch when support is good enough
			for (var key in value)
			{
				if (Object.prototype.hasOwnProperty.call(value, key))
				{
					var result = _Json_runHelp(decoder.b, value[key]);
					if (!$elm$core$Result$isOk(result))
					{
						return $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, key, result.a));
					}
					keyValuePairs = _List_Cons(_Utils_Tuple2(key, result.a), keyValuePairs);
				}
			}
			return $elm$core$Result$Ok($elm$core$List$reverse(keyValuePairs));

		case 9:
			var answer = decoder.f;
			var decoders = decoder.g;
			for (var i = 0; i < decoders.length; i++)
			{
				var result = _Json_runHelp(decoders[i], value);
				if (!$elm$core$Result$isOk(result))
				{
					return result;
				}
				answer = answer(result.a);
			}
			return $elm$core$Result$Ok(answer);

		case 10:
			var result = _Json_runHelp(decoder.b, value);
			return (!$elm$core$Result$isOk(result))
				? result
				: _Json_runHelp(decoder.h(result.a), value);

		case 11:
			var errors = _List_Nil;
			for (var temp = decoder.g; temp.b; temp = temp.b) // WHILE_CONS
			{
				var result = _Json_runHelp(temp.a, value);
				if ($elm$core$Result$isOk(result))
				{
					return result;
				}
				errors = _List_Cons(result.a, errors);
			}
			return $elm$core$Result$Err($elm$json$Json$Decode$OneOf($elm$core$List$reverse(errors)));

		case 1:
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, decoder.a, _Json_wrap(value)));

		case 0:
			return $elm$core$Result$Ok(decoder.a);
	}
}

function _Json_runArrayDecoder(decoder, value, toElmValue)
{
	var len = value.length;
	var array = new Array(len);
	for (var i = 0; i < len; i++)
	{
		var result = _Json_runHelp(decoder, value[i]);
		if (!$elm$core$Result$isOk(result))
		{
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, i, result.a));
		}
		array[i] = result.a;
	}
	return $elm$core$Result$Ok(toElmValue(array));
}

function _Json_isArray(value)
{
	return Array.isArray(value) || (typeof FileList !== 'undefined' && value instanceof FileList);
}

function _Json_toElmArray(array)
{
	return A2($elm$core$Array$initialize, array.length, function(i) { return array[i]; });
}

function _Json_expecting(type, value)
{
	return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'Expecting ' + type, _Json_wrap(value)));
}


// EQUALITY

function _Json_equality(x, y)
{
	if (x === y)
	{
		return true;
	}

	if (x.$ !== y.$)
	{
		return false;
	}

	switch (x.$)
	{
		case 0:
		case 1:
			return x.a === y.a;

		case 2:
			return x.b === y.b;

		case 5:
			return x.c === y.c;

		case 3:
		case 4:
		case 8:
			return _Json_equality(x.b, y.b);

		case 6:
			return x.d === y.d && _Json_equality(x.b, y.b);

		case 7:
			return x.e === y.e && _Json_equality(x.b, y.b);

		case 9:
			return x.f === y.f && _Json_listEquality(x.g, y.g);

		case 10:
			return x.h === y.h && _Json_equality(x.b, y.b);

		case 11:
			return _Json_listEquality(x.g, y.g);
	}
}

function _Json_listEquality(aDecoders, bDecoders)
{
	var len = aDecoders.length;
	if (len !== bDecoders.length)
	{
		return false;
	}
	for (var i = 0; i < len; i++)
	{
		if (!_Json_equality(aDecoders[i], bDecoders[i]))
		{
			return false;
		}
	}
	return true;
}


// ENCODE

var _Json_encode = F2(function(indentLevel, value)
{
	return JSON.stringify(_Json_unwrap(value), null, indentLevel) + '';
});

function _Json_wrap(value) { return { $: 0, a: value }; }
function _Json_unwrap(value) { return value.a; }

function _Json_wrap_UNUSED(value) { return value; }
function _Json_unwrap_UNUSED(value) { return value; }

function _Json_emptyArray() { return []; }
function _Json_emptyObject() { return {}; }

var _Json_addField = F3(function(key, value, object)
{
	var unwrapped = _Json_unwrap(value);
	if (!(key === 'toJSON' && typeof unwrapped === 'function'))
	{
		object[key] = unwrapped;
	}
	return object;
});

function _Json_addEntry(func)
{
	return F2(function(entry, array)
	{
		array.push(_Json_unwrap(func(entry)));
		return array;
	});
}

var _Json_encodeNull = _Json_wrap(null);



function _Process_sleep(time)
{
	return _Scheduler_binding(function(callback) {
		var id = setTimeout(function() {
			callback(_Scheduler_succeed(_Utils_Tuple0));
		}, time);

		return function() { clearTimeout(id); };
	});
}




// PROGRAMS


var _Platform_worker = F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.init,
		impl.update,
		impl.subscriptions,
		function() { return function() {} }
	);
});



// INITIALIZE A PROGRAM


function _Platform_initialize(flagDecoder, args, init, update, subscriptions, stepperBuilder)
{
	var result = A2(_Json_run, flagDecoder, _Json_wrap(args ? args['flags'] : undefined));
	$elm$core$Result$isOk(result) || _Debug_crash(2 /**/, _Json_errorToString(result.a) /**/);
	var managers = {};
	var initPair = init(result.a);
	var model = initPair.a;
	var stepper = stepperBuilder(sendToApp, model);
	var ports = _Platform_setupEffects(managers, sendToApp);

	function sendToApp(msg, viewMetadata)
	{
		var pair = A2(update, msg, model);
		stepper(model = pair.a, viewMetadata);
		_Platform_enqueueEffects(managers, pair.b, subscriptions(model));
	}

	_Platform_enqueueEffects(managers, initPair.b, subscriptions(model));

	return ports ? { ports: ports } : {};
}



// TRACK PRELOADS
//
// This is used by code in elm/browser and elm/http
// to register any HTTP requests that are triggered by init.
//


var _Platform_preload;


function _Platform_registerPreload(url)
{
	_Platform_preload.add(url);
}



// EFFECT MANAGERS


var _Platform_effectManagers = {};


function _Platform_setupEffects(managers, sendToApp)
{
	var ports;

	// setup all necessary effect managers
	for (var key in _Platform_effectManagers)
	{
		var manager = _Platform_effectManagers[key];

		if (manager.a)
		{
			ports = ports || {};
			ports[key] = manager.a(key, sendToApp);
		}

		managers[key] = _Platform_instantiateManager(manager, sendToApp);
	}

	return ports;
}


function _Platform_createManager(init, onEffects, onSelfMsg, cmdMap, subMap)
{
	return {
		b: init,
		c: onEffects,
		d: onSelfMsg,
		e: cmdMap,
		f: subMap
	};
}


function _Platform_instantiateManager(info, sendToApp)
{
	var router = {
		g: sendToApp,
		h: undefined
	};

	var onEffects = info.c;
	var onSelfMsg = info.d;
	var cmdMap = info.e;
	var subMap = info.f;

	function loop(state)
	{
		return A2(_Scheduler_andThen, loop, _Scheduler_receive(function(msg)
		{
			var value = msg.a;

			if (msg.$ === 0)
			{
				return A3(onSelfMsg, router, value, state);
			}

			return cmdMap && subMap
				? A4(onEffects, router, value.i, value.j, state)
				: A3(onEffects, router, cmdMap ? value.i : value.j, state);
		}));
	}

	return router.h = _Scheduler_rawSpawn(A2(_Scheduler_andThen, loop, info.b));
}



// ROUTING


var _Platform_sendToApp = F2(function(router, msg)
{
	return _Scheduler_binding(function(callback)
	{
		router.g(msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});


var _Platform_sendToSelf = F2(function(router, msg)
{
	return A2(_Scheduler_send, router.h, {
		$: 0,
		a: msg
	});
});



// BAGS


function _Platform_leaf(home)
{
	return function(value)
	{
		return {
			$: 1,
			k: home,
			l: value
		};
	};
}


function _Platform_batch(list)
{
	return {
		$: 2,
		m: list
	};
}


var _Platform_map = F2(function(tagger, bag)
{
	return {
		$: 3,
		n: tagger,
		o: bag
	}
});



// PIPE BAGS INTO EFFECT MANAGERS
//
// Effects must be queued!
//
// Say your init contains a synchronous command, like Time.now or Time.here
//
//   - This will produce a batch of effects (FX_1)
//   - The synchronous task triggers the subsequent `update` call
//   - This will produce a batch of effects (FX_2)
//
// If we just start dispatching FX_2, subscriptions from FX_2 can be processed
// before subscriptions from FX_1. No good! Earlier versions of this code had
// this problem, leading to these reports:
//
//   https://github.com/elm/core/issues/980
//   https://github.com/elm/core/pull/981
//   https://github.com/elm/compiler/issues/1776
//
// The queue is necessary to avoid ordering issues for synchronous commands.


// Why use true/false here? Why not just check the length of the queue?
// The goal is to detect "are we currently dispatching effects?" If we
// are, we need to bail and let the ongoing while loop handle things.
//
// Now say the queue has 1 element. When we dequeue the final element,
// the queue will be empty, but we are still actively dispatching effects.
// So you could get queue jumping in a really tricky category of cases.
//
var _Platform_effectsQueue = [];
var _Platform_effectsActive = false;


function _Platform_enqueueEffects(managers, cmdBag, subBag)
{
	_Platform_effectsQueue.push({ p: managers, q: cmdBag, r: subBag });

	if (_Platform_effectsActive) return;

	_Platform_effectsActive = true;
	for (var fx; fx = _Platform_effectsQueue.shift(); )
	{
		_Platform_dispatchEffects(fx.p, fx.q, fx.r);
	}
	_Platform_effectsActive = false;
}


function _Platform_dispatchEffects(managers, cmdBag, subBag)
{
	var effectsDict = {};
	_Platform_gatherEffects(true, cmdBag, effectsDict, null);
	_Platform_gatherEffects(false, subBag, effectsDict, null);

	for (var home in managers)
	{
		_Scheduler_rawSend(managers[home], {
			$: 'fx',
			a: effectsDict[home] || { i: _List_Nil, j: _List_Nil }
		});
	}
}


function _Platform_gatherEffects(isCmd, bag, effectsDict, taggers)
{
	switch (bag.$)
	{
		case 1:
			var home = bag.k;
			var effect = _Platform_toEffect(isCmd, home, taggers, bag.l);
			effectsDict[home] = _Platform_insert(isCmd, effect, effectsDict[home]);
			return;

		case 2:
			for (var list = bag.m; list.b; list = list.b) // WHILE_CONS
			{
				_Platform_gatherEffects(isCmd, list.a, effectsDict, taggers);
			}
			return;

		case 3:
			_Platform_gatherEffects(isCmd, bag.o, effectsDict, {
				s: bag.n,
				t: taggers
			});
			return;
	}
}


function _Platform_toEffect(isCmd, home, taggers, value)
{
	function applyTaggers(x)
	{
		for (var temp = taggers; temp; temp = temp.t)
		{
			x = temp.s(x);
		}
		return x;
	}

	var map = isCmd
		? _Platform_effectManagers[home].e
		: _Platform_effectManagers[home].f;

	return A2(map, applyTaggers, value)
}


function _Platform_insert(isCmd, newEffect, effects)
{
	effects = effects || { i: _List_Nil, j: _List_Nil };

	isCmd
		? (effects.i = _List_Cons(newEffect, effects.i))
		: (effects.j = _List_Cons(newEffect, effects.j));

	return effects;
}



// PORTS


function _Platform_checkPortName(name)
{
	if (_Platform_effectManagers[name])
	{
		_Debug_crash(3, name)
	}
}



// OUTGOING PORTS


function _Platform_outgoingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		e: _Platform_outgoingPortMap,
		u: converter,
		a: _Platform_setupOutgoingPort
	};
	return _Platform_leaf(name);
}


var _Platform_outgoingPortMap = F2(function(tagger, value) { return value; });


function _Platform_setupOutgoingPort(name)
{
	var subs = [];
	var converter = _Platform_effectManagers[name].u;

	// CREATE MANAGER

	var init = _Process_sleep(0);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, cmdList, state)
	{
		for ( ; cmdList.b; cmdList = cmdList.b) // WHILE_CONS
		{
			// grab a separate reference to subs in case unsubscribe is called
			var currentSubs = subs;
			var value = _Json_unwrap(converter(cmdList.a));
			for (var i = 0; i < currentSubs.length; i++)
			{
				currentSubs[i](value);
			}
		}
		return init;
	});

	// PUBLIC API

	function subscribe(callback)
	{
		subs.push(callback);
	}

	function unsubscribe(callback)
	{
		// copy subs into a new array in case unsubscribe is called within a
		// subscribed callback
		subs = subs.slice();
		var index = subs.indexOf(callback);
		if (index >= 0)
		{
			subs.splice(index, 1);
		}
	}

	return {
		subscribe: subscribe,
		unsubscribe: unsubscribe
	};
}



// INCOMING PORTS


function _Platform_incomingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		f: _Platform_incomingPortMap,
		u: converter,
		a: _Platform_setupIncomingPort
	};
	return _Platform_leaf(name);
}


var _Platform_incomingPortMap = F2(function(tagger, finalTagger)
{
	return function(value)
	{
		return tagger(finalTagger(value));
	};
});


function _Platform_setupIncomingPort(name, sendToApp)
{
	var subs = _List_Nil;
	var converter = _Platform_effectManagers[name].u;

	// CREATE MANAGER

	var init = _Scheduler_succeed(null);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, subList, state)
	{
		subs = subList;
		return init;
	});

	// PUBLIC API

	function send(incomingValue)
	{
		var result = A2(_Json_run, converter, _Json_wrap(incomingValue));

		$elm$core$Result$isOk(result) || _Debug_crash(4, name, result.a);

		var value = result.a;
		for (var temp = subs; temp.b; temp = temp.b) // WHILE_CONS
		{
			sendToApp(temp.a(value));
		}
	}

	return { send: send };
}



// EXPORT ELM MODULES
//
// Have DEBUG and PROD versions so that we can (1) give nicer errors in
// debug mode and (2) not pay for the bits needed for that in prod mode.
//


/*
function _Platform_export_UNUSED(exports)
{
	scope['Elm']
		? _Platform_mergeExportsProd(scope['Elm'], exports)
		: scope['Elm'] = exports;
}

*/

/*
function _Platform_mergeExportsProd(obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6)
				: _Platform_mergeExportsProd(obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}
*/


/*
function _Platform_export(exports)
{
	scope['Elm']
		? _Platform_mergeExportsDebug('Elm', scope['Elm'], exports)
		: scope['Elm'] = exports;
}

*/

/*
function _Platform_mergeExportsDebug(moduleName, obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6, moduleName)
				: _Platform_mergeExportsDebug(moduleName + '.' + name, obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}
*/



// SEND REQUEST

var _Http_toTask = F3(function(router, toTask, request)
{
	return _Scheduler_binding(function(callback)
	{
		function done(response) {
			callback(toTask(request.expect.a(response)));
		}

		var xhr = new XMLHttpRequest();
		xhr.addEventListener('error', function() { done($elm$http$Http$NetworkError_); });
		xhr.addEventListener('timeout', function() { done($elm$http$Http$Timeout_); });
		xhr.addEventListener('load', function() { done(_Http_toResponse(request.expect.b, xhr)); });
		$elm$core$Maybe$isJust(request.tracker) && _Http_track(router, xhr, request.tracker.a);

		try {
			xhr.open(request.method, request.url, true);
		} catch (e) {
			return done($elm$http$Http$BadUrl_(request.url));
		}

		_Http_configureRequest(xhr, request);

		request.body.a && xhr.setRequestHeader('Content-Type', request.body.a);
		xhr.send(request.body.b);

		return function() { xhr.c = true; xhr.abort(); };
	});
});


// CONFIGURE

function _Http_configureRequest(xhr, request)
{
	for (var headers = request.headers; headers.b; headers = headers.b) // WHILE_CONS
	{
		xhr.setRequestHeader(headers.a.a, headers.a.b);
	}
	xhr.timeout = request.timeout.a || 0;
	xhr.responseType = request.expect.d;
	xhr.withCredentials = request.allowCookiesFromOtherDomains;
}


// RESPONSES

function _Http_toResponse(toBody, xhr)
{
	return A2(
		200 <= xhr.status && xhr.status < 300 ? $elm$http$Http$GoodStatus_ : $elm$http$Http$BadStatus_,
		_Http_toMetadata(xhr),
		toBody(xhr.response)
	);
}


// METADATA

function _Http_toMetadata(xhr)
{
	return {
		url: xhr.responseURL,
		statusCode: xhr.status,
		statusText: xhr.statusText,
		headers: _Http_parseHeaders(xhr.getAllResponseHeaders())
	};
}


// HEADERS

function _Http_parseHeaders(rawHeaders)
{
	if (!rawHeaders)
	{
		return $elm$core$Dict$empty;
	}

	var headers = $elm$core$Dict$empty;
	var headerPairs = rawHeaders.split('\r\n');
	for (var i = headerPairs.length; i--; )
	{
		var headerPair = headerPairs[i];
		var index = headerPair.indexOf(': ');
		if (index > 0)
		{
			var key = headerPair.substring(0, index);
			var value = headerPair.substring(index + 2);

			headers = A3($elm$core$Dict$update, key, function(oldValue) {
				return $elm$core$Maybe$Just($elm$core$Maybe$isJust(oldValue)
					? value + ', ' + oldValue.a
					: value
				);
			}, headers);
		}
	}
	return headers;
}


// EXPECT

var _Http_expect = F3(function(type, toBody, toValue)
{
	return {
		$: 0,
		d: type,
		b: toBody,
		a: toValue
	};
});

var _Http_mapExpect = F2(function(func, expect)
{
	return {
		$: 0,
		d: expect.d,
		b: expect.b,
		a: function(x) { return func(expect.a(x)); }
	};
});

function _Http_toDataView(arrayBuffer)
{
	return new DataView(arrayBuffer);
}


// BODY and PARTS

var _Http_emptyBody = { $: 0 };
var _Http_pair = F2(function(a, b) { return { $: 0, a: a, b: b }; });

function _Http_toFormData(parts)
{
	for (var formData = new FormData(); parts.b; parts = parts.b) // WHILE_CONS
	{
		var part = parts.a;
		formData.append(part.a, part.b);
	}
	return formData;
}

var _Http_bytesToBlob = F2(function(mime, bytes)
{
	return new Blob([bytes], { type: mime });
});


// PROGRESS

function _Http_track(router, xhr, tracker)
{
	// TODO check out lengthComputable on loadstart event

	xhr.upload.addEventListener('progress', function(event) {
		if (xhr.c) { return; }
		_Scheduler_rawSpawn(A2($elm$core$Platform$sendToSelf, router, _Utils_Tuple2(tracker, $elm$http$Http$Sending({
			sent: event.loaded,
			size: event.total
		}))));
	});
	xhr.addEventListener('progress', function(event) {
		if (xhr.c) { return; }
		_Scheduler_rawSpawn(A2($elm$core$Platform$sendToSelf, router, _Utils_Tuple2(tracker, $elm$http$Http$Receiving({
			received: event.loaded,
			size: event.lengthComputable ? $elm$core$Maybe$Just(event.total) : $elm$core$Maybe$Nothing
		}))));
	});
}var $elm$core$List$cons = _List_cons;
var $elm$core$Elm$JsArray$foldr = _JsArray_foldr;
var $elm$core$Array$foldr = F3(
	function (func, baseCase, _v0) {
		var tree = _v0.c;
		var tail = _v0.d;
		var helper = F2(
			function (node, acc) {
				if (node.$ === 'SubTree') {
					var subTree = node.a;
					return A3($elm$core$Elm$JsArray$foldr, helper, acc, subTree);
				} else {
					var values = node.a;
					return A3($elm$core$Elm$JsArray$foldr, func, acc, values);
				}
			});
		return A3(
			$elm$core$Elm$JsArray$foldr,
			helper,
			A3($elm$core$Elm$JsArray$foldr, func, baseCase, tail),
			tree);
	});
var $elm$core$Array$toList = function (array) {
	return A3($elm$core$Array$foldr, $elm$core$List$cons, _List_Nil, array);
};
var $elm$core$Dict$foldr = F3(
	function (func, acc, t) {
		foldr:
		while (true) {
			if (t.$ === 'RBEmpty_elm_builtin') {
				return acc;
			} else {
				var key = t.b;
				var value = t.c;
				var left = t.d;
				var right = t.e;
				var $temp$func = func,
					$temp$acc = A3(
					func,
					key,
					value,
					A3($elm$core$Dict$foldr, func, acc, right)),
					$temp$t = left;
				func = $temp$func;
				acc = $temp$acc;
				t = $temp$t;
				continue foldr;
			}
		}
	});
var $elm$core$Dict$toList = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, list) {
				return A2(
					$elm$core$List$cons,
					_Utils_Tuple2(key, value),
					list);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Dict$keys = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, keyList) {
				return A2($elm$core$List$cons, key, keyList);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Set$toList = function (_v0) {
	var dict = _v0.a;
	return $elm$core$Dict$keys(dict);
};
var $elm$core$Basics$EQ = {$: 'EQ'};
var $elm$core$Basics$GT = {$: 'GT'};
var $elm$core$Basics$LT = {$: 'LT'};
var $author$project$Server$AuthLogoutResponse = F2(
	function (a, b) {
		return {$: 'AuthLogoutResponse', a: a, b: b};
	});
var $author$project$Server$AuthSelfResponse = F2(
	function (a, b) {
		return {$: 'AuthSelfResponse', a: a, b: b};
	});
var $author$project$Http$Status$BadRequest = {$: 'BadRequest'};
var $author$project$Http$Extended$Field = function (a) {
	return {$: 'Field', a: a};
};
var $author$project$Http$Extended$Generic = function (a) {
	return {$: 'Generic', a: a};
};
var $author$project$Server$LoginResponse = F2(
	function (a, b) {
		return {$: 'LoginResponse', a: a, b: b};
	});
var $author$project$Http$Status$NotFound = {$: 'NotFound'};
var $author$project$Server$OrganizationCreateResponse = F2(
	function (a, b) {
		return {$: 'OrganizationCreateResponse', a: a, b: b};
	});
var $author$project$Http$Method$Post = {$: 'Post'};
var $elm$core$Basics$composeR = F3(
	function (f, g, x) {
		return g(
			f(x));
	});
var $elm$core$Basics$apR = F2(
	function (x, f) {
		return f(x);
	});
var $elm$core$Maybe$Just = function (a) {
	return {$: 'Just', a: a};
};
var $elm$core$Maybe$Nothing = {$: 'Nothing'};
var $elm$bytes$Bytes$Encode$getWidth = function (builder) {
	switch (builder.$) {
		case 'I8':
			return 1;
		case 'I16':
			return 2;
		case 'I32':
			return 4;
		case 'U8':
			return 1;
		case 'U16':
			return 2;
		case 'U32':
			return 4;
		case 'F32':
			return 4;
		case 'F64':
			return 8;
		case 'Seq':
			var w = builder.a;
			return w;
		case 'Utf8':
			var w = builder.a;
			return w;
		default:
			var bs = builder.a;
			return _Bytes_width(bs);
	}
};
var $elm$bytes$Bytes$LE = {$: 'LE'};
var $elm$core$Basics$eq = _Utils_equal;
var $elm$bytes$Bytes$Encode$write = F3(
	function (builder, mb, offset) {
		switch (builder.$) {
			case 'I8':
				var n = builder.a;
				return A3(_Bytes_write_i8, mb, offset, n);
			case 'I16':
				var e = builder.a;
				var n = builder.b;
				return A4(
					_Bytes_write_i16,
					mb,
					offset,
					n,
					_Utils_eq(e, $elm$bytes$Bytes$LE));
			case 'I32':
				var e = builder.a;
				var n = builder.b;
				return A4(
					_Bytes_write_i32,
					mb,
					offset,
					n,
					_Utils_eq(e, $elm$bytes$Bytes$LE));
			case 'U8':
				var n = builder.a;
				return A3(_Bytes_write_u8, mb, offset, n);
			case 'U16':
				var e = builder.a;
				var n = builder.b;
				return A4(
					_Bytes_write_u16,
					mb,
					offset,
					n,
					_Utils_eq(e, $elm$bytes$Bytes$LE));
			case 'U32':
				var e = builder.a;
				var n = builder.b;
				return A4(
					_Bytes_write_u32,
					mb,
					offset,
					n,
					_Utils_eq(e, $elm$bytes$Bytes$LE));
			case 'F32':
				var e = builder.a;
				var n = builder.b;
				return A4(
					_Bytes_write_f32,
					mb,
					offset,
					n,
					_Utils_eq(e, $elm$bytes$Bytes$LE));
			case 'F64':
				var e = builder.a;
				var n = builder.b;
				return A4(
					_Bytes_write_f64,
					mb,
					offset,
					n,
					_Utils_eq(e, $elm$bytes$Bytes$LE));
			case 'Seq':
				var bs = builder.b;
				return A3($elm$bytes$Bytes$Encode$writeSequence, bs, mb, offset);
			case 'Utf8':
				var s = builder.b;
				return A3(_Bytes_write_string, mb, offset, s);
			default:
				var bs = builder.a;
				return A3(_Bytes_write_bytes, mb, offset, bs);
		}
	});
var $elm$bytes$Bytes$Encode$writeSequence = F3(
	function (builders, mb, offset) {
		writeSequence:
		while (true) {
			if (!builders.b) {
				return offset;
			} else {
				var b = builders.a;
				var bs = builders.b;
				var $temp$builders = bs,
					$temp$mb = mb,
					$temp$offset = A3($elm$bytes$Bytes$Encode$write, b, mb, offset);
				builders = $temp$builders;
				mb = $temp$mb;
				offset = $temp$offset;
				continue writeSequence;
			}
		}
	});
var $elm$bytes$Bytes$Encode$encode = _Bytes_encode;
var $elm$bytes$Bytes$Encode$Seq = F2(
	function (a, b) {
		return {$: 'Seq', a: a, b: b};
	});
var $elm$core$Basics$add = _Basics_add;
var $elm$bytes$Bytes$Encode$getWidths = F2(
	function (width, builders) {
		getWidths:
		while (true) {
			if (!builders.b) {
				return width;
			} else {
				var b = builders.a;
				var bs = builders.b;
				var $temp$width = width + $elm$bytes$Bytes$Encode$getWidth(b),
					$temp$builders = bs;
				width = $temp$width;
				builders = $temp$builders;
				continue getWidths;
			}
		}
	});
var $elm$bytes$Bytes$Encode$sequence = function (builders) {
	return A2(
		$elm$bytes$Bytes$Encode$Seq,
		A2($elm$bytes$Bytes$Encode$getWidths, 0, builders),
		builders);
};
var $author$project$Serialize$toBytesEncoder = function (_v0) {
	var m = _v0.a;
	return m.encoder;
};
var $author$project$Serialize$encodeToBytes = F2(
	function (codec, value) {
		return $elm$bytes$Bytes$Encode$encode(
			$elm$bytes$Bytes$Encode$sequence(
				_List_fromArray(
					[
						A2($author$project$Serialize$toBytesEncoder, codec, value)
					])));
	});
var $elm$bytes$Bytes$Decode$decode = F2(
	function (_v0, bs) {
		var decoder = _v0.a;
		return A2(_Bytes_decode, decoder, bs);
	});
var $elm$core$Basics$identity = function (x) {
	return x;
};
var $elm$bytes$Bytes$Decode$Decoder = function (a) {
	return {$: 'Decoder', a: a};
};
var $elm$bytes$Bytes$Decode$loopHelp = F4(
	function (state, callback, bites, offset) {
		loopHelp:
		while (true) {
			var _v0 = callback(state);
			var decoder = _v0.a;
			var _v1 = A2(decoder, bites, offset);
			var newOffset = _v1.a;
			var step = _v1.b;
			if (step.$ === 'Loop') {
				var newState = step.a;
				var $temp$state = newState,
					$temp$callback = callback,
					$temp$bites = bites,
					$temp$offset = newOffset;
				state = $temp$state;
				callback = $temp$callback;
				bites = $temp$bites;
				offset = $temp$offset;
				continue loopHelp;
			} else {
				var result = step.a;
				return _Utils_Tuple2(newOffset, result);
			}
		}
	});
var $elm$bytes$Bytes$Decode$loop = F2(
	function (state, callback) {
		return $elm$bytes$Bytes$Decode$Decoder(
			A2($elm$bytes$Bytes$Decode$loopHelp, state, callback));
	});
var $elm$bytes$Bytes$Decode$Done = function (a) {
	return {$: 'Done', a: a};
};
var $elm$bytes$Bytes$Decode$Loop = function (a) {
	return {$: 'Loop', a: a};
};
var $elm$core$Basics$append = _Utils_append;
var $elm$core$Bitwise$and = _Bitwise_and;
var $elm$core$String$cons = _String_cons;
var $elm$core$String$fromChar = function (_char) {
	return A2($elm$core$String$cons, _char, '');
};
var $danfishgold$base64_bytes$Decode$lowest6BitsMask = 63;
var $elm$core$Bitwise$shiftRightZfBy = _Bitwise_shiftRightZfBy;
var $elm$core$Char$fromCode = _Char_fromCode;
var $elm$core$Basics$le = _Utils_le;
var $elm$core$Basics$sub = _Basics_sub;
var $danfishgold$base64_bytes$Decode$unsafeToChar = function (n) {
	if (n <= 25) {
		return $elm$core$Char$fromCode(65 + n);
	} else {
		if (n <= 51) {
			return $elm$core$Char$fromCode(97 + (n - 26));
		} else {
			if (n <= 61) {
				return $elm$core$Char$fromCode(48 + (n - 52));
			} else {
				switch (n) {
					case 62:
						return _Utils_chr('+');
					case 63:
						return _Utils_chr('/');
					default:
						return _Utils_chr('\u0000');
				}
			}
		}
	}
};
var $danfishgold$base64_bytes$Decode$bitsToChars = F2(
	function (bits, missing) {
		var s = $danfishgold$base64_bytes$Decode$unsafeToChar(bits & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
		var r = $danfishgold$base64_bytes$Decode$unsafeToChar((bits >>> 6) & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
		var q = $danfishgold$base64_bytes$Decode$unsafeToChar((bits >>> 12) & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
		var p = $danfishgold$base64_bytes$Decode$unsafeToChar(bits >>> 18);
		switch (missing) {
			case 0:
				return A2(
					$elm$core$String$cons,
					p,
					A2(
						$elm$core$String$cons,
						q,
						A2(
							$elm$core$String$cons,
							r,
							$elm$core$String$fromChar(s))));
			case 1:
				return A2(
					$elm$core$String$cons,
					p,
					A2(
						$elm$core$String$cons,
						q,
						A2($elm$core$String$cons, r, '=')));
			case 2:
				return A2(
					$elm$core$String$cons,
					p,
					A2($elm$core$String$cons, q, '=='));
			default:
				return '';
		}
	});
var $danfishgold$base64_bytes$Decode$bitsToCharSpecialized = F4(
	function (bits1, bits2, bits3, accum) {
		var z = $danfishgold$base64_bytes$Decode$unsafeToChar((bits3 >>> 6) & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
		var y = $danfishgold$base64_bytes$Decode$unsafeToChar((bits3 >>> 12) & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
		var x = $danfishgold$base64_bytes$Decode$unsafeToChar(bits3 >>> 18);
		var w = $danfishgold$base64_bytes$Decode$unsafeToChar(bits3 & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
		var s = $danfishgold$base64_bytes$Decode$unsafeToChar(bits1 & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
		var r = $danfishgold$base64_bytes$Decode$unsafeToChar((bits1 >>> 6) & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
		var q = $danfishgold$base64_bytes$Decode$unsafeToChar((bits1 >>> 12) & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
		var p = $danfishgold$base64_bytes$Decode$unsafeToChar(bits1 >>> 18);
		var d = $danfishgold$base64_bytes$Decode$unsafeToChar(bits2 & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
		var c = $danfishgold$base64_bytes$Decode$unsafeToChar((bits2 >>> 6) & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
		var b = $danfishgold$base64_bytes$Decode$unsafeToChar((bits2 >>> 12) & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
		var a = $danfishgold$base64_bytes$Decode$unsafeToChar(bits2 >>> 18);
		return A2(
			$elm$core$String$cons,
			x,
			A2(
				$elm$core$String$cons,
				y,
				A2(
					$elm$core$String$cons,
					z,
					A2(
						$elm$core$String$cons,
						w,
						A2(
							$elm$core$String$cons,
							a,
							A2(
								$elm$core$String$cons,
								b,
								A2(
									$elm$core$String$cons,
									c,
									A2(
										$elm$core$String$cons,
										d,
										A2(
											$elm$core$String$cons,
											p,
											A2(
												$elm$core$String$cons,
												q,
												A2(
													$elm$core$String$cons,
													r,
													A2($elm$core$String$cons, s, accum))))))))))));
	});
var $elm$core$Bitwise$or = _Bitwise_or;
var $elm$core$Bitwise$shiftLeftBy = _Bitwise_shiftLeftBy;
var $danfishgold$base64_bytes$Decode$decode18Help = F5(
	function (a, b, c, d, e) {
		var combined6 = ((255 & d) << 16) | e;
		var combined5 = d >>> 8;
		var combined4 = 16777215 & c;
		var combined3 = ((65535 & b) << 8) | (c >>> 24);
		var combined2 = ((255 & a) << 16) | (b >>> 16);
		var combined1 = a >>> 8;
		return A4(
			$danfishgold$base64_bytes$Decode$bitsToCharSpecialized,
			combined3,
			combined2,
			combined1,
			A4($danfishgold$base64_bytes$Decode$bitsToCharSpecialized, combined6, combined5, combined4, ''));
	});
var $elm$core$Basics$apL = F2(
	function (f, x) {
		return f(x);
	});
var $elm$bytes$Bytes$Decode$map5 = F6(
	function (func, _v0, _v1, _v2, _v3, _v4) {
		var decodeA = _v0.a;
		var decodeB = _v1.a;
		var decodeC = _v2.a;
		var decodeD = _v3.a;
		var decodeE = _v4.a;
		return $elm$bytes$Bytes$Decode$Decoder(
			F2(
				function (bites, offset) {
					var _v5 = A2(decodeA, bites, offset);
					var aOffset = _v5.a;
					var a = _v5.b;
					var _v6 = A2(decodeB, bites, aOffset);
					var bOffset = _v6.a;
					var b = _v6.b;
					var _v7 = A2(decodeC, bites, bOffset);
					var cOffset = _v7.a;
					var c = _v7.b;
					var _v8 = A2(decodeD, bites, cOffset);
					var dOffset = _v8.a;
					var d = _v8.b;
					var _v9 = A2(decodeE, bites, dOffset);
					var eOffset = _v9.a;
					var e = _v9.b;
					return _Utils_Tuple2(
						eOffset,
						A5(func, a, b, c, d, e));
				}));
	});
var $elm$bytes$Bytes$BE = {$: 'BE'};
var $elm$bytes$Bytes$Decode$unsignedInt16 = function (endianness) {
	return $elm$bytes$Bytes$Decode$Decoder(
		_Bytes_read_u16(
			_Utils_eq(endianness, $elm$bytes$Bytes$LE)));
};
var $danfishgold$base64_bytes$Decode$u16BE = $elm$bytes$Bytes$Decode$unsignedInt16($elm$bytes$Bytes$BE);
var $elm$bytes$Bytes$Decode$unsignedInt32 = function (endianness) {
	return $elm$bytes$Bytes$Decode$Decoder(
		_Bytes_read_u32(
			_Utils_eq(endianness, $elm$bytes$Bytes$LE)));
};
var $danfishgold$base64_bytes$Decode$u32BE = $elm$bytes$Bytes$Decode$unsignedInt32($elm$bytes$Bytes$BE);
var $danfishgold$base64_bytes$Decode$decode18Bytes = A6($elm$bytes$Bytes$Decode$map5, $danfishgold$base64_bytes$Decode$decode18Help, $danfishgold$base64_bytes$Decode$u32BE, $danfishgold$base64_bytes$Decode$u32BE, $danfishgold$base64_bytes$Decode$u32BE, $danfishgold$base64_bytes$Decode$u32BE, $danfishgold$base64_bytes$Decode$u16BE);
var $elm$core$Basics$ge = _Utils_ge;
var $elm$bytes$Bytes$Decode$map = F2(
	function (func, _v0) {
		var decodeA = _v0.a;
		return $elm$bytes$Bytes$Decode$Decoder(
			F2(
				function (bites, offset) {
					var _v1 = A2(decodeA, bites, offset);
					var aOffset = _v1.a;
					var a = _v1.b;
					return _Utils_Tuple2(
						aOffset,
						func(a));
				}));
	});
var $elm$bytes$Bytes$Decode$map2 = F3(
	function (func, _v0, _v1) {
		var decodeA = _v0.a;
		var decodeB = _v1.a;
		return $elm$bytes$Bytes$Decode$Decoder(
			F2(
				function (bites, offset) {
					var _v2 = A2(decodeA, bites, offset);
					var aOffset = _v2.a;
					var a = _v2.b;
					var _v3 = A2(decodeB, bites, aOffset);
					var bOffset = _v3.a;
					var b = _v3.b;
					return _Utils_Tuple2(
						bOffset,
						A2(func, a, b));
				}));
	});
var $elm$bytes$Bytes$Decode$map3 = F4(
	function (func, _v0, _v1, _v2) {
		var decodeA = _v0.a;
		var decodeB = _v1.a;
		var decodeC = _v2.a;
		return $elm$bytes$Bytes$Decode$Decoder(
			F2(
				function (bites, offset) {
					var _v3 = A2(decodeA, bites, offset);
					var aOffset = _v3.a;
					var a = _v3.b;
					var _v4 = A2(decodeB, bites, aOffset);
					var bOffset = _v4.a;
					var b = _v4.b;
					var _v5 = A2(decodeC, bites, bOffset);
					var cOffset = _v5.a;
					var c = _v5.b;
					return _Utils_Tuple2(
						cOffset,
						A3(func, a, b, c));
				}));
	});
var $elm$bytes$Bytes$Decode$succeed = function (a) {
	return $elm$bytes$Bytes$Decode$Decoder(
		F2(
			function (_v0, offset) {
				return _Utils_Tuple2(offset, a);
			}));
};
var $elm$bytes$Bytes$Decode$unsignedInt8 = $elm$bytes$Bytes$Decode$Decoder(_Bytes_read_u8);
var $danfishgold$base64_bytes$Decode$loopHelp = function (_v0) {
	var remaining = _v0.remaining;
	var string = _v0.string;
	if (remaining >= 18) {
		return A2(
			$elm$bytes$Bytes$Decode$map,
			function (result) {
				return $elm$bytes$Bytes$Decode$Loop(
					{
						remaining: remaining - 18,
						string: _Utils_ap(string, result)
					});
			},
			$danfishgold$base64_bytes$Decode$decode18Bytes);
	} else {
		if (remaining >= 3) {
			var helper = F3(
				function (a, b, c) {
					var combined = ((a << 16) | (b << 8)) | c;
					return $elm$bytes$Bytes$Decode$Loop(
						{
							remaining: remaining - 3,
							string: _Utils_ap(
								string,
								A2($danfishgold$base64_bytes$Decode$bitsToChars, combined, 0))
						});
				});
			return A4($elm$bytes$Bytes$Decode$map3, helper, $elm$bytes$Bytes$Decode$unsignedInt8, $elm$bytes$Bytes$Decode$unsignedInt8, $elm$bytes$Bytes$Decode$unsignedInt8);
		} else {
			if (!remaining) {
				return $elm$bytes$Bytes$Decode$succeed(
					$elm$bytes$Bytes$Decode$Done(string));
			} else {
				if (remaining === 2) {
					var helper = F2(
						function (a, b) {
							var combined = (a << 16) | (b << 8);
							return $elm$bytes$Bytes$Decode$Done(
								_Utils_ap(
									string,
									A2($danfishgold$base64_bytes$Decode$bitsToChars, combined, 1)));
						});
					return A3($elm$bytes$Bytes$Decode$map2, helper, $elm$bytes$Bytes$Decode$unsignedInt8, $elm$bytes$Bytes$Decode$unsignedInt8);
				} else {
					return A2(
						$elm$bytes$Bytes$Decode$map,
						function (a) {
							return $elm$bytes$Bytes$Decode$Done(
								_Utils_ap(
									string,
									A2($danfishgold$base64_bytes$Decode$bitsToChars, a << 16, 2)));
						},
						$elm$bytes$Bytes$Decode$unsignedInt8);
				}
			}
		}
	}
};
var $danfishgold$base64_bytes$Decode$decoder = function (width) {
	return A2(
		$elm$bytes$Bytes$Decode$loop,
		{remaining: width, string: ''},
		$danfishgold$base64_bytes$Decode$loopHelp);
};
var $elm$bytes$Bytes$width = _Bytes_width;
var $danfishgold$base64_bytes$Decode$fromBytes = function (bytes) {
	return A2(
		$elm$bytes$Bytes$Decode$decode,
		$danfishgold$base64_bytes$Decode$decoder(
			$elm$bytes$Bytes$width(bytes)),
		bytes);
};
var $danfishgold$base64_bytes$Base64$fromBytes = $danfishgold$base64_bytes$Decode$fromBytes;
var $elm$regex$Regex$Match = F4(
	function (match, index, number, submatches) {
		return {index: index, match: match, number: number, submatches: submatches};
	});
var $elm$regex$Regex$replace = _Regex_replaceAtMost(_Regex_infinity);
var $elm$core$Basics$False = {$: 'False'};
var $elm$regex$Regex$fromStringWith = _Regex_fromStringWith;
var $elm$regex$Regex$fromString = function (string) {
	return A2(
		$elm$regex$Regex$fromStringWith,
		{caseInsensitive: false, multiline: false},
		string);
};
var $elm$regex$Regex$never = _Regex_never;
var $elm$core$Maybe$withDefault = F2(
	function (_default, maybe) {
		if (maybe.$ === 'Just') {
			var value = maybe.a;
			return value;
		} else {
			return _default;
		}
	});
var $author$project$Serialize$replaceForUrl = A2(
	$elm$core$Maybe$withDefault,
	$elm$regex$Regex$never,
	$elm$regex$Regex$fromString('[\\+/=]'));
var $author$project$Serialize$replaceBase64Chars = function () {
	var replaceChar = function (rematch) {
		var _v0 = rematch.match;
		switch (_v0) {
			case '+':
				return '-';
			case '/':
				return '_';
			default:
				return '';
		}
	};
	return A2(
		$elm$core$Basics$composeR,
		$danfishgold$base64_bytes$Base64$fromBytes,
		A2(
			$elm$core$Basics$composeR,
			$elm$core$Maybe$withDefault(''),
			A2($elm$regex$Regex$replace, $author$project$Serialize$replaceForUrl, replaceChar)));
}();
var $author$project$Serialize$encodeToString = function (codec) {
	return A2(
		$elm$core$Basics$composeR,
		$author$project$Serialize$encodeToBytes(codec),
		$author$project$Serialize$replaceBase64Chars);
};
var $author$project$Serialize$CustomTypeCodec = function (a) {
	return {$: 'CustomTypeCodec', a: a};
};
var $author$project$Serialize$customType = function (match) {
	return $author$project$Serialize$CustomTypeCodec(
		{
			decoder: function (_v0) {
				return $elm$core$Basics$identity;
			},
			idCounter: 0,
			match: match
		});
};
var $author$project$Serialize$RecordCodec = function (a) {
	return {$: 'RecordCodec', a: a};
};
var $author$project$Serialize$toBytesDecoder = function (_v0) {
	var m = _v0.a;
	return m.decoder;
};
var $author$project$Serialize$field = F3(
	function (getter, codec, _v0) {
		var recordCodec = _v0.a;
		return $author$project$Serialize$RecordCodec(
			{
				decoder: A3(
					$elm$bytes$Bytes$Decode$map2,
					F2(
						function (cons, fieldVal) {
							return cons(fieldVal);
						}),
					recordCodec.decoder,
					$author$project$Serialize$toBytesDecoder(codec)),
				encoder: function (v) {
					return A2(
						$elm$core$List$cons,
						A2(
							$author$project$Serialize$toBytesEncoder,
							codec,
							getter(v)),
						recordCodec.encoder(v));
				}
			});
	});
var $author$project$Serialize$Codec = function (a) {
	return {$: 'Codec', a: a};
};
var $author$project$Serialize$finishRecord = function (_v0) {
	var codec = _v0.a;
	return $author$project$Serialize$Codec(
		{
			decoder: codec.decoder,
			encoder: A2($elm$core$Basics$composeR, codec.encoder, $elm$bytes$Bytes$Encode$sequence)
		});
};
var $author$project$Serialize$record = function (ctor) {
	return $author$project$Serialize$RecordCodec(
		{
			decoder: $elm$bytes$Bytes$Decode$succeed(ctor),
			encoder: function (_v0) {
				return _List_Nil;
			}
		});
};
var $elm$bytes$Bytes$Decode$andThen = F2(
	function (callback, _v0) {
		var decodeA = _v0.a;
		return $elm$bytes$Bytes$Decode$Decoder(
			F2(
				function (bites, offset) {
					var _v1 = A2(decodeA, bites, offset);
					var newOffset = _v1.a;
					var a = _v1.b;
					var _v2 = callback(a);
					var decodeB = _v2.a;
					return A2(decodeB, bites, newOffset);
				}));
	});
var $author$project$Serialize$build = F2(
	function (encoder_, decoder_) {
		return $author$project$Serialize$Codec(
			{decoder: decoder_, encoder: encoder_});
	});
var $author$project$Serialize$endian = $elm$bytes$Bytes$BE;
var $elm$bytes$Bytes$Encode$getStringWidth = _Bytes_getStringWidth;
var $elm$bytes$Bytes$Decode$string = function (n) {
	return $elm$bytes$Bytes$Decode$Decoder(
		_Bytes_read_string(n));
};
var $elm$bytes$Bytes$Encode$Utf8 = F2(
	function (a, b) {
		return {$: 'Utf8', a: a, b: b};
	});
var $elm$bytes$Bytes$Encode$string = function (str) {
	return A2(
		$elm$bytes$Bytes$Encode$Utf8,
		_Bytes_getStringWidth(str),
		str);
};
var $elm$bytes$Bytes$Encode$U32 = F2(
	function (a, b) {
		return {$: 'U32', a: a, b: b};
	});
var $elm$bytes$Bytes$Encode$unsignedInt32 = $elm$bytes$Bytes$Encode$U32;
var $author$project$Serialize$string = A2(
	$author$project$Serialize$build,
	function (text) {
		return $elm$bytes$Bytes$Encode$sequence(
			_List_fromArray(
				[
					A2(
					$elm$bytes$Bytes$Encode$unsignedInt32,
					$author$project$Serialize$endian,
					$elm$bytes$Bytes$Encode$getStringWidth(text)),
					$elm$bytes$Bytes$Encode$string(text)
				]));
	},
	A2(
		$elm$bytes$Bytes$Decode$andThen,
		$elm$bytes$Bytes$Decode$string,
		$elm$bytes$Bytes$Decode$unsignedInt32($author$project$Serialize$endian)));
var $author$project$Http$Extended$fieldErrorCodec = $author$project$Serialize$finishRecord(
	A3(
		$author$project$Serialize$field,
		function ($) {
			return $.message;
		},
		$author$project$Serialize$string,
		A3(
			$author$project$Serialize$field,
			function ($) {
				return $.name;
			},
			$author$project$Serialize$string,
			$author$project$Serialize$record(
				F2(
					function (name, message) {
						return {message: message, name: name};
					})))));
var $elm$bytes$Bytes$Decode$fail = $elm$bytes$Bytes$Decode$Decoder(_Bytes_decodeFailure);
var $author$project$Serialize$finishCustomType = function (_v0) {
	var am = _v0.a;
	return A2(
		$author$project$Serialize$build,
		A2(
			$elm$core$Basics$composeR,
			am.match,
			function (_v1) {
				var _v2 = _v1.a;
				var a = _v2.a;
				return a;
			}),
		A2(
			$elm$bytes$Bytes$Decode$andThen,
			function (tag) {
				return A2(am.decoder, tag, $elm$bytes$Bytes$Decode$fail);
			},
			$elm$bytes$Bytes$Decode$unsignedInt16($author$project$Serialize$endian)));
};
var $author$project$Serialize$VariantEncoder = function (a) {
	return {$: 'VariantEncoder', a: a};
};
var $elm$core$Result$Err = function (a) {
	return {$: 'Err', a: a};
};
var $elm$json$Json$Decode$Failure = F2(
	function (a, b) {
		return {$: 'Failure', a: a, b: b};
	});
var $elm$json$Json$Decode$Field = F2(
	function (a, b) {
		return {$: 'Field', a: a, b: b};
	});
var $elm$json$Json$Decode$Index = F2(
	function (a, b) {
		return {$: 'Index', a: a, b: b};
	});
var $elm$core$Result$Ok = function (a) {
	return {$: 'Ok', a: a};
};
var $elm$json$Json$Decode$OneOf = function (a) {
	return {$: 'OneOf', a: a};
};
var $elm$core$String$all = _String_all;
var $elm$core$Basics$and = _Basics_and;
var $elm$json$Json$Encode$encode = _Json_encode;
var $elm$core$String$fromInt = _String_fromNumber;
var $elm$core$String$join = F2(
	function (sep, chunks) {
		return A2(
			_String_join,
			sep,
			_List_toArray(chunks));
	});
var $elm$core$String$split = F2(
	function (sep, string) {
		return _List_fromArray(
			A2(_String_split, sep, string));
	});
var $elm$json$Json$Decode$indent = function (str) {
	return A2(
		$elm$core$String$join,
		'\n    ',
		A2($elm$core$String$split, '\n', str));
};
var $elm$core$List$foldl = F3(
	function (func, acc, list) {
		foldl:
		while (true) {
			if (!list.b) {
				return acc;
			} else {
				var x = list.a;
				var xs = list.b;
				var $temp$func = func,
					$temp$acc = A2(func, x, acc),
					$temp$list = xs;
				func = $temp$func;
				acc = $temp$acc;
				list = $temp$list;
				continue foldl;
			}
		}
	});
var $elm$core$List$length = function (xs) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (_v0, i) {
				return i + 1;
			}),
		0,
		xs);
};
var $elm$core$List$map2 = _List_map2;
var $elm$core$List$rangeHelp = F3(
	function (lo, hi, list) {
		rangeHelp:
		while (true) {
			if (_Utils_cmp(lo, hi) < 1) {
				var $temp$lo = lo,
					$temp$hi = hi - 1,
					$temp$list = A2($elm$core$List$cons, hi, list);
				lo = $temp$lo;
				hi = $temp$hi;
				list = $temp$list;
				continue rangeHelp;
			} else {
				return list;
			}
		}
	});
var $elm$core$List$range = F2(
	function (lo, hi) {
		return A3($elm$core$List$rangeHelp, lo, hi, _List_Nil);
	});
var $elm$core$List$indexedMap = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$map2,
			f,
			A2(
				$elm$core$List$range,
				0,
				$elm$core$List$length(xs) - 1),
			xs);
	});
var $elm$core$Char$toCode = _Char_toCode;
var $elm$core$Char$isLower = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (97 <= code) && (code <= 122);
};
var $elm$core$Char$isUpper = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 90) && (65 <= code);
};
var $elm$core$Basics$or = _Basics_or;
var $elm$core$Char$isAlpha = function (_char) {
	return $elm$core$Char$isLower(_char) || $elm$core$Char$isUpper(_char);
};
var $elm$core$Char$isDigit = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 57) && (48 <= code);
};
var $elm$core$Char$isAlphaNum = function (_char) {
	return $elm$core$Char$isLower(_char) || ($elm$core$Char$isUpper(_char) || $elm$core$Char$isDigit(_char));
};
var $elm$core$List$reverse = function (list) {
	return A3($elm$core$List$foldl, $elm$core$List$cons, _List_Nil, list);
};
var $elm$core$String$uncons = _String_uncons;
var $elm$json$Json$Decode$errorOneOf = F2(
	function (i, error) {
		return '\n\n(' + ($elm$core$String$fromInt(i + 1) + (') ' + $elm$json$Json$Decode$indent(
			$elm$json$Json$Decode$errorToString(error))));
	});
var $elm$json$Json$Decode$errorToString = function (error) {
	return A2($elm$json$Json$Decode$errorToStringHelp, error, _List_Nil);
};
var $elm$json$Json$Decode$errorToStringHelp = F2(
	function (error, context) {
		errorToStringHelp:
		while (true) {
			switch (error.$) {
				case 'Field':
					var f = error.a;
					var err = error.b;
					var isSimple = function () {
						var _v1 = $elm$core$String$uncons(f);
						if (_v1.$ === 'Nothing') {
							return false;
						} else {
							var _v2 = _v1.a;
							var _char = _v2.a;
							var rest = _v2.b;
							return $elm$core$Char$isAlpha(_char) && A2($elm$core$String$all, $elm$core$Char$isAlphaNum, rest);
						}
					}();
					var fieldName = isSimple ? ('.' + f) : ('[\'' + (f + '\']'));
					var $temp$error = err,
						$temp$context = A2($elm$core$List$cons, fieldName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 'Index':
					var i = error.a;
					var err = error.b;
					var indexName = '[' + ($elm$core$String$fromInt(i) + ']');
					var $temp$error = err,
						$temp$context = A2($elm$core$List$cons, indexName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 'OneOf':
					var errors = error.a;
					if (!errors.b) {
						return 'Ran into a Json.Decode.oneOf with no possibilities' + function () {
							if (!context.b) {
								return '!';
							} else {
								return ' at json' + A2(
									$elm$core$String$join,
									'',
									$elm$core$List$reverse(context));
							}
						}();
					} else {
						if (!errors.b.b) {
							var err = errors.a;
							var $temp$error = err,
								$temp$context = context;
							error = $temp$error;
							context = $temp$context;
							continue errorToStringHelp;
						} else {
							var starter = function () {
								if (!context.b) {
									return 'Json.Decode.oneOf';
								} else {
									return 'The Json.Decode.oneOf at json' + A2(
										$elm$core$String$join,
										'',
										$elm$core$List$reverse(context));
								}
							}();
							var introduction = starter + (' failed in the following ' + ($elm$core$String$fromInt(
								$elm$core$List$length(errors)) + ' ways:'));
							return A2(
								$elm$core$String$join,
								'\n\n',
								A2(
									$elm$core$List$cons,
									introduction,
									A2($elm$core$List$indexedMap, $elm$json$Json$Decode$errorOneOf, errors)));
						}
					}
				default:
					var msg = error.a;
					var json = error.b;
					var introduction = function () {
						if (!context.b) {
							return 'Problem with the given value:\n\n';
						} else {
							return 'Problem with the value at json' + (A2(
								$elm$core$String$join,
								'',
								$elm$core$List$reverse(context)) + ':\n\n    ');
						}
					}();
					return introduction + ($elm$json$Json$Decode$indent(
						A2($elm$json$Json$Encode$encode, 4, json)) + ('\n\n' + msg));
			}
		}
	});
var $elm$core$Array$branchFactor = 32;
var $elm$core$Array$Array_elm_builtin = F4(
	function (a, b, c, d) {
		return {$: 'Array_elm_builtin', a: a, b: b, c: c, d: d};
	});
var $elm$core$Elm$JsArray$empty = _JsArray_empty;
var $elm$core$Basics$ceiling = _Basics_ceiling;
var $elm$core$Basics$fdiv = _Basics_fdiv;
var $elm$core$Basics$logBase = F2(
	function (base, number) {
		return _Basics_log(number) / _Basics_log(base);
	});
var $elm$core$Basics$toFloat = _Basics_toFloat;
var $elm$core$Array$shiftStep = $elm$core$Basics$ceiling(
	A2($elm$core$Basics$logBase, 2, $elm$core$Array$branchFactor));
var $elm$core$Array$empty = A4($elm$core$Array$Array_elm_builtin, 0, $elm$core$Array$shiftStep, $elm$core$Elm$JsArray$empty, $elm$core$Elm$JsArray$empty);
var $elm$core$Elm$JsArray$initialize = _JsArray_initialize;
var $elm$core$Array$Leaf = function (a) {
	return {$: 'Leaf', a: a};
};
var $elm$core$Basics$floor = _Basics_floor;
var $elm$core$Elm$JsArray$length = _JsArray_length;
var $elm$core$Basics$gt = _Utils_gt;
var $elm$core$Basics$max = F2(
	function (x, y) {
		return (_Utils_cmp(x, y) > 0) ? x : y;
	});
var $elm$core$Basics$mul = _Basics_mul;
var $elm$core$Array$SubTree = function (a) {
	return {$: 'SubTree', a: a};
};
var $elm$core$Elm$JsArray$initializeFromList = _JsArray_initializeFromList;
var $elm$core$Array$compressNodes = F2(
	function (nodes, acc) {
		compressNodes:
		while (true) {
			var _v0 = A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodes);
			var node = _v0.a;
			var remainingNodes = _v0.b;
			var newAcc = A2(
				$elm$core$List$cons,
				$elm$core$Array$SubTree(node),
				acc);
			if (!remainingNodes.b) {
				return $elm$core$List$reverse(newAcc);
			} else {
				var $temp$nodes = remainingNodes,
					$temp$acc = newAcc;
				nodes = $temp$nodes;
				acc = $temp$acc;
				continue compressNodes;
			}
		}
	});
var $elm$core$Tuple$first = function (_v0) {
	var x = _v0.a;
	return x;
};
var $elm$core$Array$treeFromBuilder = F2(
	function (nodeList, nodeListSize) {
		treeFromBuilder:
		while (true) {
			var newNodeSize = $elm$core$Basics$ceiling(nodeListSize / $elm$core$Array$branchFactor);
			if (newNodeSize === 1) {
				return A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodeList).a;
			} else {
				var $temp$nodeList = A2($elm$core$Array$compressNodes, nodeList, _List_Nil),
					$temp$nodeListSize = newNodeSize;
				nodeList = $temp$nodeList;
				nodeListSize = $temp$nodeListSize;
				continue treeFromBuilder;
			}
		}
	});
var $elm$core$Array$builderToArray = F2(
	function (reverseNodeList, builder) {
		if (!builder.nodeListSize) {
			return A4(
				$elm$core$Array$Array_elm_builtin,
				$elm$core$Elm$JsArray$length(builder.tail),
				$elm$core$Array$shiftStep,
				$elm$core$Elm$JsArray$empty,
				builder.tail);
		} else {
			var treeLen = builder.nodeListSize * $elm$core$Array$branchFactor;
			var depth = $elm$core$Basics$floor(
				A2($elm$core$Basics$logBase, $elm$core$Array$branchFactor, treeLen - 1));
			var correctNodeList = reverseNodeList ? $elm$core$List$reverse(builder.nodeList) : builder.nodeList;
			var tree = A2($elm$core$Array$treeFromBuilder, correctNodeList, builder.nodeListSize);
			return A4(
				$elm$core$Array$Array_elm_builtin,
				$elm$core$Elm$JsArray$length(builder.tail) + treeLen,
				A2($elm$core$Basics$max, 5, depth * $elm$core$Array$shiftStep),
				tree,
				builder.tail);
		}
	});
var $elm$core$Basics$idiv = _Basics_idiv;
var $elm$core$Basics$lt = _Utils_lt;
var $elm$core$Array$initializeHelp = F5(
	function (fn, fromIndex, len, nodeList, tail) {
		initializeHelp:
		while (true) {
			if (fromIndex < 0) {
				return A2(
					$elm$core$Array$builderToArray,
					false,
					{nodeList: nodeList, nodeListSize: (len / $elm$core$Array$branchFactor) | 0, tail: tail});
			} else {
				var leaf = $elm$core$Array$Leaf(
					A3($elm$core$Elm$JsArray$initialize, $elm$core$Array$branchFactor, fromIndex, fn));
				var $temp$fn = fn,
					$temp$fromIndex = fromIndex - $elm$core$Array$branchFactor,
					$temp$len = len,
					$temp$nodeList = A2($elm$core$List$cons, leaf, nodeList),
					$temp$tail = tail;
				fn = $temp$fn;
				fromIndex = $temp$fromIndex;
				len = $temp$len;
				nodeList = $temp$nodeList;
				tail = $temp$tail;
				continue initializeHelp;
			}
		}
	});
var $elm$core$Basics$remainderBy = _Basics_remainderBy;
var $elm$core$Array$initialize = F2(
	function (len, fn) {
		if (len <= 0) {
			return $elm$core$Array$empty;
		} else {
			var tailLen = len % $elm$core$Array$branchFactor;
			var tail = A3($elm$core$Elm$JsArray$initialize, tailLen, len - tailLen, fn);
			var initialFromIndex = (len - tailLen) - $elm$core$Array$branchFactor;
			return A5($elm$core$Array$initializeHelp, fn, initialFromIndex, len, _List_Nil, tail);
		}
	});
var $elm$core$Basics$True = {$: 'True'};
var $elm$core$Result$isOk = function (result) {
	if (result.$ === 'Ok') {
		return true;
	} else {
		return false;
	}
};
var $elm$json$Json$Encode$null = _Json_encodeNull;
var $elm$bytes$Bytes$Encode$U16 = F2(
	function (a, b) {
		return {$: 'U16', a: a, b: b};
	});
var $elm$bytes$Bytes$Encode$unsignedInt16 = $elm$bytes$Bytes$Encode$U16;
var $author$project$Serialize$variant = F3(
	function (matchPiece, decoderPiece, _v0) {
		var am = _v0.a;
		var enc = function (v) {
			return $author$project$Serialize$VariantEncoder(
				_Utils_Tuple2(
					$elm$bytes$Bytes$Encode$sequence(
						A2(
							$elm$core$List$cons,
							A2($elm$bytes$Bytes$Encode$unsignedInt16, $author$project$Serialize$endian, am.idCounter),
							v)),
					$elm$json$Json$Encode$null));
		};
		var decoder_ = F2(
			function (tag, orElse) {
				return _Utils_eq(tag, am.idCounter) ? decoderPiece : A2(am.decoder, tag, orElse);
			});
		return $author$project$Serialize$CustomTypeCodec(
			{
				decoder: decoder_,
				idCounter: am.idCounter + 1,
				match: am.match(
					matchPiece(enc))
			});
	});
var $author$project$Serialize$variant1 = F2(
	function (ctor, m1) {
		return A2(
			$author$project$Serialize$variant,
			F2(
				function (c, v) {
					return c(
						_List_fromArray(
							[
								A2($author$project$Serialize$toBytesEncoder, m1, v)
							]));
				}),
			A2(
				$elm$bytes$Bytes$Decode$map,
				ctor,
				$author$project$Serialize$toBytesDecoder(m1)));
	});
var $author$project$Http$Extended$errorCodec = $author$project$Serialize$finishCustomType(
	A3(
		$author$project$Serialize$variant1,
		$author$project$Http$Extended$Generic,
		$author$project$Serialize$string,
		A3(
			$author$project$Serialize$variant1,
			$author$project$Http$Extended$Field,
			$author$project$Http$Extended$fieldErrorCodec,
			$author$project$Serialize$customType(
				F3(
					function (fieldEncoder, genericEncoder, value) {
						if (value.$ === 'Field') {
							var v = value.a;
							return fieldEncoder(v);
						} else {
							var v = value.a;
							return genericEncoder(v);
						}
					})))));
var $elm$core$Debug$log = _Debug_log;
var $elm$json$Json$Encode$int = _Json_wrap;
var $elm$json$Json$Encode$list = F2(
	function (func, entries) {
		return _Json_wrap(
			A3(
				$elm$core$List$foldl,
				_Json_addEntry(func),
				_Json_emptyArray(_Utils_Tuple0),
				entries));
	});
var $elm$json$Json$Encode$object = function (pairs) {
	return _Json_wrap(
		A3(
			$elm$core$List$foldl,
			F2(
				function (_v0, obj) {
					var k = _v0.a;
					var v = _v0.b;
					return A3(_Json_addField, k, v, obj);
				}),
			_Json_emptyObject(_Utils_Tuple0),
			pairs));
};
var $elm$json$Json$Encode$string = _Json_wrap;
var $author$project$Http$Status$toInt = function (status) {
	switch (status.$) {
		case 'Continue':
			return 100;
		case 'SwitchingProtocols':
			return 101;
		case 'Processing':
			return 102;
		case 'EarlyHints':
			return 103;
		case 'StatusOk':
			return 200;
		case 'Created':
			return 201;
		case 'Accepted':
			return 202;
		case 'NonAuthoritativeInformation':
			return 203;
		case 'NoContent':
			return 204;
		case 'ResetContent':
			return 205;
		case 'PartialContent':
			return 206;
		case 'MultiStatus':
			return 207;
		case 'AlreadyReported':
			return 208;
		case 'IMUsed':
			return 226;
		case 'MultipleChoices':
			return 300;
		case 'MovedPermanently':
			return 301;
		case 'Found':
			return 302;
		case 'SeeOther':
			return 303;
		case 'NotModified':
			return 304;
		case 'UseProxy':
			return 305;
		case 'SwitchProxy':
			return 306;
		case 'TemporaryRedirect':
			return 307;
		case 'PermanentRedirect':
			return 308;
		case 'BadRequest':
			return 400;
		case 'Unauthorized':
			return 401;
		case 'PaymentRequired':
			return 402;
		case 'Forbidden':
			return 403;
		case 'NotFound':
			return 404;
		case 'MethodNotAllowed':
			return 405;
		case 'NotAcceptable':
			return 406;
		case 'ProxyAuthenticationRequired':
			return 407;
		case 'RequestTimeout':
			return 408;
		case 'Conflict':
			return 409;
		case 'Gone':
			return 410;
		case 'LengthRequired':
			return 411;
		case 'PreconditionFailed':
			return 412;
		case 'PayloadTooLarge':
			return 413;
		case 'URITooLong':
			return 414;
		case 'UnsupportedMediaType':
			return 415;
		case 'RangeNotSatisfiable':
			return 416;
		case 'ExpectationFailed':
			return 417;
		case 'ImATeapot':
			return 418;
		case 'MisdirectedRequest':
			return 421;
		case 'UnprocessableEntity':
			return 422;
		case 'Locked':
			return 423;
		case 'FailedDependency':
			return 424;
		case 'TooEarly':
			return 425;
		case 'UpgradeRequired':
			return 426;
		case 'PreconditionRequired':
			return 428;
		case 'TooManyRequests':
			return 429;
		case 'RequestHeaderFieldsTooLarge':
			return 431;
		case 'UnavailableForLegalReasons':
			return 451;
		case 'InternalServerError':
			return 500;
		case 'NotImplemented':
			return 501;
		case 'BadGateway':
			return 502;
		case 'ServiceUnavailable':
			return 503;
		case 'GatewayTimeout':
			return 504;
		case 'HTTPVersionNotSupported':
			return 505;
		case 'VariantAlsoNegotiates':
			return 506;
		case 'InsufficientStorage':
			return 507;
		case 'LoopDetected':
			return 508;
		case 'NotExtended':
			return 510;
		case 'NetworkAuthenticationRequired':
			return 511;
		default:
			var code = status.a;
			return code;
	}
};
var $author$project$Http$Extended$responseEncode = function (response) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'status',
				$elm$json$Json$Encode$int(
					$author$project$Http$Status$toInt(response.status))),
				_Utils_Tuple2(
				'headers',
				A2(
					$elm$json$Json$Encode$list,
					function (_v0) {
						var key = _v0.a;
						var value = _v0.b;
						return A2(
							$elm$json$Json$Encode$list,
							$elm$json$Json$Encode$string,
							_List_fromArray(
								[key, value]));
					},
					response.headers)),
				_Utils_Tuple2(
				'body',
				$elm$json$Json$Encode$string(response.body))
			]));
};
var $author$project$Server$sendResponse = _Platform_outgoingPort('sendResponse', $elm$core$Basics$identity);
var $author$project$Server$respond = function (response) {
	return $author$project$Server$sendResponse(
		$author$project$Http$Extended$responseEncode(
			A2($elm$core$Debug$log, 'response', response)));
};
var $author$project$Server$acadiaFailureResponse = function (config) {
	return $author$project$Server$respond(
		{
			body: A2($author$project$Serialize$encodeToString, $author$project$Http$Extended$errorCodec, config.error),
			headers: _List_Nil,
			status: config.status
		});
};
var $elm$http$Http$BadStatus_ = F2(
	function (a, b) {
		return {$: 'BadStatus_', a: a, b: b};
	});
var $elm$http$Http$BadUrl_ = function (a) {
	return {$: 'BadUrl_', a: a};
};
var $elm$http$Http$GoodStatus_ = F2(
	function (a, b) {
		return {$: 'GoodStatus_', a: a, b: b};
	});
var $elm$http$Http$NetworkError_ = {$: 'NetworkError_'};
var $elm$http$Http$Receiving = function (a) {
	return {$: 'Receiving', a: a};
};
var $elm$http$Http$Sending = function (a) {
	return {$: 'Sending', a: a};
};
var $elm$http$Http$Timeout_ = {$: 'Timeout_'};
var $elm$core$Dict$RBEmpty_elm_builtin = {$: 'RBEmpty_elm_builtin'};
var $elm$core$Dict$empty = $elm$core$Dict$RBEmpty_elm_builtin;
var $elm$core$Maybe$isJust = function (maybe) {
	if (maybe.$ === 'Just') {
		return true;
	} else {
		return false;
	}
};
var $elm$core$Platform$sendToSelf = _Platform_sendToSelf;
var $elm$core$Basics$compare = _Utils_compare;
var $elm$core$Dict$get = F2(
	function (targetKey, dict) {
		get:
		while (true) {
			if (dict.$ === 'RBEmpty_elm_builtin') {
				return $elm$core$Maybe$Nothing;
			} else {
				var key = dict.b;
				var value = dict.c;
				var left = dict.d;
				var right = dict.e;
				var _v1 = A2($elm$core$Basics$compare, targetKey, key);
				switch (_v1.$) {
					case 'LT':
						var $temp$targetKey = targetKey,
							$temp$dict = left;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
					case 'EQ':
						return $elm$core$Maybe$Just(value);
					default:
						var $temp$targetKey = targetKey,
							$temp$dict = right;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
				}
			}
		}
	});
var $elm$core$Dict$Black = {$: 'Black'};
var $elm$core$Dict$RBNode_elm_builtin = F5(
	function (a, b, c, d, e) {
		return {$: 'RBNode_elm_builtin', a: a, b: b, c: c, d: d, e: e};
	});
var $elm$core$Dict$Red = {$: 'Red'};
var $elm$core$Dict$balance = F5(
	function (color, key, value, left, right) {
		if ((right.$ === 'RBNode_elm_builtin') && (right.a.$ === 'Red')) {
			var _v1 = right.a;
			var rK = right.b;
			var rV = right.c;
			var rLeft = right.d;
			var rRight = right.e;
			if ((left.$ === 'RBNode_elm_builtin') && (left.a.$ === 'Red')) {
				var _v3 = left.a;
				var lK = left.b;
				var lV = left.c;
				var lLeft = left.d;
				var lRight = left.e;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Red,
					key,
					value,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					color,
					rK,
					rV,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, key, value, left, rLeft),
					rRight);
			}
		} else {
			if ((((left.$ === 'RBNode_elm_builtin') && (left.a.$ === 'Red')) && (left.d.$ === 'RBNode_elm_builtin')) && (left.d.a.$ === 'Red')) {
				var _v5 = left.a;
				var lK = left.b;
				var lV = left.c;
				var _v6 = left.d;
				var _v7 = _v6.a;
				var llK = _v6.b;
				var llV = _v6.c;
				var llLeft = _v6.d;
				var llRight = _v6.e;
				var lRight = left.e;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Red,
					lK,
					lV,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, llK, llV, llLeft, llRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, key, value, lRight, right));
			} else {
				return A5($elm$core$Dict$RBNode_elm_builtin, color, key, value, left, right);
			}
		}
	});
var $elm$core$Dict$insertHelp = F3(
	function (key, value, dict) {
		if (dict.$ === 'RBEmpty_elm_builtin') {
			return A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, key, value, $elm$core$Dict$RBEmpty_elm_builtin, $elm$core$Dict$RBEmpty_elm_builtin);
		} else {
			var nColor = dict.a;
			var nKey = dict.b;
			var nValue = dict.c;
			var nLeft = dict.d;
			var nRight = dict.e;
			var _v1 = A2($elm$core$Basics$compare, key, nKey);
			switch (_v1.$) {
				case 'LT':
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						A3($elm$core$Dict$insertHelp, key, value, nLeft),
						nRight);
				case 'EQ':
					return A5($elm$core$Dict$RBNode_elm_builtin, nColor, nKey, value, nLeft, nRight);
				default:
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						nLeft,
						A3($elm$core$Dict$insertHelp, key, value, nRight));
			}
		}
	});
var $elm$core$Dict$insert = F3(
	function (key, value, dict) {
		var _v0 = A3($elm$core$Dict$insertHelp, key, value, dict);
		if ((_v0.$ === 'RBNode_elm_builtin') && (_v0.a.$ === 'Red')) {
			var _v1 = _v0.a;
			var k = _v0.b;
			var v = _v0.c;
			var l = _v0.d;
			var r = _v0.e;
			return A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, k, v, l, r);
		} else {
			var x = _v0;
			return x;
		}
	});
var $elm$core$Dict$getMin = function (dict) {
	getMin:
	while (true) {
		if ((dict.$ === 'RBNode_elm_builtin') && (dict.d.$ === 'RBNode_elm_builtin')) {
			var left = dict.d;
			var $temp$dict = left;
			dict = $temp$dict;
			continue getMin;
		} else {
			return dict;
		}
	}
};
var $elm$core$Dict$moveRedLeft = function (dict) {
	if (((dict.$ === 'RBNode_elm_builtin') && (dict.d.$ === 'RBNode_elm_builtin')) && (dict.e.$ === 'RBNode_elm_builtin')) {
		if ((dict.e.d.$ === 'RBNode_elm_builtin') && (dict.e.d.a.$ === 'Red')) {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v1 = dict.d;
			var lClr = _v1.a;
			var lK = _v1.b;
			var lV = _v1.c;
			var lLeft = _v1.d;
			var lRight = _v1.e;
			var _v2 = dict.e;
			var rClr = _v2.a;
			var rK = _v2.b;
			var rV = _v2.c;
			var rLeft = _v2.d;
			var _v3 = rLeft.a;
			var rlK = rLeft.b;
			var rlV = rLeft.c;
			var rlL = rLeft.d;
			var rlR = rLeft.e;
			var rRight = _v2.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				$elm$core$Dict$Red,
				rlK,
				rlV,
				A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, lK, lV, lLeft, lRight),
					rlL),
				A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, rK, rV, rlR, rRight));
		} else {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v4 = dict.d;
			var lClr = _v4.a;
			var lK = _v4.b;
			var lV = _v4.c;
			var lLeft = _v4.d;
			var lRight = _v4.e;
			var _v5 = dict.e;
			var rClr = _v5.a;
			var rK = _v5.b;
			var rV = _v5.c;
			var rLeft = _v5.d;
			var rRight = _v5.e;
			if (clr.$ === 'Black') {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, rK, rV, rLeft, rRight));
			}
		}
	} else {
		return dict;
	}
};
var $elm$core$Dict$moveRedRight = function (dict) {
	if (((dict.$ === 'RBNode_elm_builtin') && (dict.d.$ === 'RBNode_elm_builtin')) && (dict.e.$ === 'RBNode_elm_builtin')) {
		if ((dict.d.d.$ === 'RBNode_elm_builtin') && (dict.d.d.a.$ === 'Red')) {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v1 = dict.d;
			var lClr = _v1.a;
			var lK = _v1.b;
			var lV = _v1.c;
			var _v2 = _v1.d;
			var _v3 = _v2.a;
			var llK = _v2.b;
			var llV = _v2.c;
			var llLeft = _v2.d;
			var llRight = _v2.e;
			var lRight = _v1.e;
			var _v4 = dict.e;
			var rClr = _v4.a;
			var rK = _v4.b;
			var rV = _v4.c;
			var rLeft = _v4.d;
			var rRight = _v4.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				$elm$core$Dict$Red,
				lK,
				lV,
				A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, llK, llV, llLeft, llRight),
				A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					lRight,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, rK, rV, rLeft, rRight)));
		} else {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v5 = dict.d;
			var lClr = _v5.a;
			var lK = _v5.b;
			var lV = _v5.c;
			var lLeft = _v5.d;
			var lRight = _v5.e;
			var _v6 = dict.e;
			var rClr = _v6.a;
			var rK = _v6.b;
			var rV = _v6.c;
			var rLeft = _v6.d;
			var rRight = _v6.e;
			if (clr.$ === 'Black') {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, rK, rV, rLeft, rRight));
			}
		}
	} else {
		return dict;
	}
};
var $elm$core$Dict$removeHelpPrepEQGT = F7(
	function (targetKey, dict, color, key, value, left, right) {
		if ((left.$ === 'RBNode_elm_builtin') && (left.a.$ === 'Red')) {
			var _v1 = left.a;
			var lK = left.b;
			var lV = left.c;
			var lLeft = left.d;
			var lRight = left.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				color,
				lK,
				lV,
				lLeft,
				A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, key, value, lRight, right));
		} else {
			_v2$2:
			while (true) {
				if ((right.$ === 'RBNode_elm_builtin') && (right.a.$ === 'Black')) {
					if (right.d.$ === 'RBNode_elm_builtin') {
						if (right.d.a.$ === 'Black') {
							var _v3 = right.a;
							var _v4 = right.d;
							var _v5 = _v4.a;
							return $elm$core$Dict$moveRedRight(dict);
						} else {
							break _v2$2;
						}
					} else {
						var _v6 = right.a;
						var _v7 = right.d;
						return $elm$core$Dict$moveRedRight(dict);
					}
				} else {
					break _v2$2;
				}
			}
			return dict;
		}
	});
var $elm$core$Dict$removeMin = function (dict) {
	if ((dict.$ === 'RBNode_elm_builtin') && (dict.d.$ === 'RBNode_elm_builtin')) {
		var color = dict.a;
		var key = dict.b;
		var value = dict.c;
		var left = dict.d;
		var lColor = left.a;
		var lLeft = left.d;
		var right = dict.e;
		if (lColor.$ === 'Black') {
			if ((lLeft.$ === 'RBNode_elm_builtin') && (lLeft.a.$ === 'Red')) {
				var _v3 = lLeft.a;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					color,
					key,
					value,
					$elm$core$Dict$removeMin(left),
					right);
			} else {
				var _v4 = $elm$core$Dict$moveRedLeft(dict);
				if (_v4.$ === 'RBNode_elm_builtin') {
					var nColor = _v4.a;
					var nKey = _v4.b;
					var nValue = _v4.c;
					var nLeft = _v4.d;
					var nRight = _v4.e;
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						$elm$core$Dict$removeMin(nLeft),
						nRight);
				} else {
					return $elm$core$Dict$RBEmpty_elm_builtin;
				}
			}
		} else {
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				color,
				key,
				value,
				$elm$core$Dict$removeMin(left),
				right);
		}
	} else {
		return $elm$core$Dict$RBEmpty_elm_builtin;
	}
};
var $elm$core$Dict$removeHelp = F2(
	function (targetKey, dict) {
		if (dict.$ === 'RBEmpty_elm_builtin') {
			return $elm$core$Dict$RBEmpty_elm_builtin;
		} else {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			if (_Utils_cmp(targetKey, key) < 0) {
				if ((left.$ === 'RBNode_elm_builtin') && (left.a.$ === 'Black')) {
					var _v4 = left.a;
					var lLeft = left.d;
					if ((lLeft.$ === 'RBNode_elm_builtin') && (lLeft.a.$ === 'Red')) {
						var _v6 = lLeft.a;
						return A5(
							$elm$core$Dict$RBNode_elm_builtin,
							color,
							key,
							value,
							A2($elm$core$Dict$removeHelp, targetKey, left),
							right);
					} else {
						var _v7 = $elm$core$Dict$moveRedLeft(dict);
						if (_v7.$ === 'RBNode_elm_builtin') {
							var nColor = _v7.a;
							var nKey = _v7.b;
							var nValue = _v7.c;
							var nLeft = _v7.d;
							var nRight = _v7.e;
							return A5(
								$elm$core$Dict$balance,
								nColor,
								nKey,
								nValue,
								A2($elm$core$Dict$removeHelp, targetKey, nLeft),
								nRight);
						} else {
							return $elm$core$Dict$RBEmpty_elm_builtin;
						}
					}
				} else {
					return A5(
						$elm$core$Dict$RBNode_elm_builtin,
						color,
						key,
						value,
						A2($elm$core$Dict$removeHelp, targetKey, left),
						right);
				}
			} else {
				return A2(
					$elm$core$Dict$removeHelpEQGT,
					targetKey,
					A7($elm$core$Dict$removeHelpPrepEQGT, targetKey, dict, color, key, value, left, right));
			}
		}
	});
var $elm$core$Dict$removeHelpEQGT = F2(
	function (targetKey, dict) {
		if (dict.$ === 'RBNode_elm_builtin') {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			if (_Utils_eq(targetKey, key)) {
				var _v1 = $elm$core$Dict$getMin(right);
				if (_v1.$ === 'RBNode_elm_builtin') {
					var minKey = _v1.b;
					var minValue = _v1.c;
					return A5(
						$elm$core$Dict$balance,
						color,
						minKey,
						minValue,
						left,
						$elm$core$Dict$removeMin(right));
				} else {
					return $elm$core$Dict$RBEmpty_elm_builtin;
				}
			} else {
				return A5(
					$elm$core$Dict$balance,
					color,
					key,
					value,
					left,
					A2($elm$core$Dict$removeHelp, targetKey, right));
			}
		} else {
			return $elm$core$Dict$RBEmpty_elm_builtin;
		}
	});
var $elm$core$Dict$remove = F2(
	function (key, dict) {
		var _v0 = A2($elm$core$Dict$removeHelp, key, dict);
		if ((_v0.$ === 'RBNode_elm_builtin') && (_v0.a.$ === 'Red')) {
			var _v1 = _v0.a;
			var k = _v0.b;
			var v = _v0.c;
			var l = _v0.d;
			var r = _v0.e;
			return A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, k, v, l, r);
		} else {
			var x = _v0;
			return x;
		}
	});
var $elm$core$Dict$update = F3(
	function (targetKey, alter, dictionary) {
		var _v0 = alter(
			A2($elm$core$Dict$get, targetKey, dictionary));
		if (_v0.$ === 'Just') {
			var value = _v0.a;
			return A3($elm$core$Dict$insert, targetKey, value, dictionary);
		} else {
			return A2($elm$core$Dict$remove, targetKey, dictionary);
		}
	});
var $elm$http$Http$bytesBody = _Http_pair;
var $elm$http$Http$BadBody = function (a) {
	return {$: 'BadBody', a: a};
};
var $elm$http$Http$BadStatus = function (a) {
	return {$: 'BadStatus', a: a};
};
var $elm$http$Http$BadUrl = function (a) {
	return {$: 'BadUrl', a: a};
};
var $elm$http$Http$NetworkError = {$: 'NetworkError'};
var $elm$http$Http$Timeout = {$: 'Timeout'};
var $author$project$Server$bytesResponseWithHeaders = F2(
	function (dec, response) {
		switch (response.$) {
			case 'BadUrl_':
				var url = response.a;
				return $elm$core$Result$Err(
					$elm$http$Http$BadUrl(url));
			case 'Timeout_':
				return $elm$core$Result$Err($elm$http$Http$Timeout);
			case 'NetworkError_':
				return $elm$core$Result$Err($elm$http$Http$NetworkError);
			case 'BadStatus_':
				var metadata = response.a;
				return $elm$core$Result$Err(
					$elm$http$Http$BadStatus(metadata.statusCode));
			default:
				var metadata = response.a;
				var body = response.b;
				var _v1 = A2($elm$bytes$Bytes$Decode$decode, dec, body);
				if (_v1.$ === 'Nothing') {
					return $elm$core$Result$Err(
						$elm$http$Http$BadBody('Failed to decode'));
				} else {
					var data = _v1.a;
					return $elm$core$Result$Ok(
						_Utils_Tuple2(
							$elm$core$Dict$toList(metadata.headers),
							data));
				}
		}
	});
var $elm$http$Http$expectBytesResponse = F2(
	function (toMsg, toResult) {
		return A3(
			_Http_expect,
			'arraybuffer',
			_Http_toDataView,
			A2($elm$core$Basics$composeR, toResult, toMsg));
	});
var $elm$core$List$foldrHelper = F4(
	function (fn, acc, ctr, ls) {
		if (!ls.b) {
			return acc;
		} else {
			var a = ls.a;
			var r1 = ls.b;
			if (!r1.b) {
				return A2(fn, a, acc);
			} else {
				var b = r1.a;
				var r2 = r1.b;
				if (!r2.b) {
					return A2(
						fn,
						a,
						A2(fn, b, acc));
				} else {
					var c = r2.a;
					var r3 = r2.b;
					if (!r3.b) {
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(fn, c, acc)));
					} else {
						var d = r3.a;
						var r4 = r3.b;
						var res = (ctr > 500) ? A3(
							$elm$core$List$foldl,
							fn,
							acc,
							$elm$core$List$reverse(r4)) : A4($elm$core$List$foldrHelper, fn, acc, ctr + 1, r4);
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(
									fn,
									c,
									A2(fn, d, res))));
					}
				}
			}
		}
	});
var $elm$core$List$foldr = F3(
	function (fn, acc, ls) {
		return A4($elm$core$List$foldrHelper, fn, acc, 0, ls);
	});
var $elm$core$List$maybeCons = F3(
	function (f, mx, xs) {
		var _v0 = f(mx);
		if (_v0.$ === 'Just') {
			var x = _v0.a;
			return A2($elm$core$List$cons, x, xs);
		} else {
			return xs;
		}
	});
var $elm$core$List$filterMap = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$foldr,
			$elm$core$List$maybeCons(f),
			_List_Nil,
			xs);
	});
var $elm$http$Http$Header = F2(
	function (a, b) {
		return {$: 'Header', a: a, b: b};
	});
var $elm$http$Http$header = $elm$http$Http$Header;
var $elm$http$Http$Request = function (a) {
	return {$: 'Request', a: a};
};
var $elm$http$Http$State = F2(
	function (reqs, subs) {
		return {reqs: reqs, subs: subs};
	});
var $elm$core$Task$succeed = _Scheduler_succeed;
var $elm$http$Http$init = $elm$core$Task$succeed(
	A2($elm$http$Http$State, $elm$core$Dict$empty, _List_Nil));
var $elm$core$Task$andThen = _Scheduler_andThen;
var $elm$core$Process$kill = _Scheduler_kill;
var $elm$core$Platform$sendToApp = _Platform_sendToApp;
var $elm$core$Process$spawn = _Scheduler_spawn;
var $elm$http$Http$updateReqs = F3(
	function (router, cmds, reqs) {
		updateReqs:
		while (true) {
			if (!cmds.b) {
				return $elm$core$Task$succeed(reqs);
			} else {
				var cmd = cmds.a;
				var otherCmds = cmds.b;
				if (cmd.$ === 'Cancel') {
					var tracker = cmd.a;
					var _v2 = A2($elm$core$Dict$get, tracker, reqs);
					if (_v2.$ === 'Nothing') {
						var $temp$router = router,
							$temp$cmds = otherCmds,
							$temp$reqs = reqs;
						router = $temp$router;
						cmds = $temp$cmds;
						reqs = $temp$reqs;
						continue updateReqs;
					} else {
						var pid = _v2.a;
						return A2(
							$elm$core$Task$andThen,
							function (_v3) {
								return A3(
									$elm$http$Http$updateReqs,
									router,
									otherCmds,
									A2($elm$core$Dict$remove, tracker, reqs));
							},
							$elm$core$Process$kill(pid));
					}
				} else {
					var req = cmd.a;
					return A2(
						$elm$core$Task$andThen,
						function (pid) {
							var _v4 = req.tracker;
							if (_v4.$ === 'Nothing') {
								return A3($elm$http$Http$updateReqs, router, otherCmds, reqs);
							} else {
								var tracker = _v4.a;
								return A3(
									$elm$http$Http$updateReqs,
									router,
									otherCmds,
									A3($elm$core$Dict$insert, tracker, pid, reqs));
							}
						},
						$elm$core$Process$spawn(
							A3(
								_Http_toTask,
								router,
								$elm$core$Platform$sendToApp(router),
								req)));
				}
			}
		}
	});
var $elm$http$Http$onEffects = F4(
	function (router, cmds, subs, state) {
		return A2(
			$elm$core$Task$andThen,
			function (reqs) {
				return $elm$core$Task$succeed(
					A2($elm$http$Http$State, reqs, subs));
			},
			A3($elm$http$Http$updateReqs, router, cmds, state.reqs));
	});
var $elm$http$Http$maybeSend = F4(
	function (router, desiredTracker, progress, _v0) {
		var actualTracker = _v0.a;
		var toMsg = _v0.b;
		return _Utils_eq(desiredTracker, actualTracker) ? $elm$core$Maybe$Just(
			A2(
				$elm$core$Platform$sendToApp,
				router,
				toMsg(progress))) : $elm$core$Maybe$Nothing;
	});
var $elm$core$Task$map2 = F3(
	function (func, taskA, taskB) {
		return A2(
			$elm$core$Task$andThen,
			function (a) {
				return A2(
					$elm$core$Task$andThen,
					function (b) {
						return $elm$core$Task$succeed(
							A2(func, a, b));
					},
					taskB);
			},
			taskA);
	});
var $elm$core$Task$sequence = function (tasks) {
	return A3(
		$elm$core$List$foldr,
		$elm$core$Task$map2($elm$core$List$cons),
		$elm$core$Task$succeed(_List_Nil),
		tasks);
};
var $elm$http$Http$onSelfMsg = F3(
	function (router, _v0, state) {
		var tracker = _v0.a;
		var progress = _v0.b;
		return A2(
			$elm$core$Task$andThen,
			function (_v1) {
				return $elm$core$Task$succeed(state);
			},
			$elm$core$Task$sequence(
				A2(
					$elm$core$List$filterMap,
					A3($elm$http$Http$maybeSend, router, tracker, progress),
					state.subs)));
	});
var $elm$http$Http$Cancel = function (a) {
	return {$: 'Cancel', a: a};
};
var $elm$http$Http$cmdMap = F2(
	function (func, cmd) {
		if (cmd.$ === 'Cancel') {
			var tracker = cmd.a;
			return $elm$http$Http$Cancel(tracker);
		} else {
			var r = cmd.a;
			return $elm$http$Http$Request(
				{
					allowCookiesFromOtherDomains: r.allowCookiesFromOtherDomains,
					body: r.body,
					expect: A2(_Http_mapExpect, func, r.expect),
					headers: r.headers,
					method: r.method,
					timeout: r.timeout,
					tracker: r.tracker,
					url: r.url
				});
		}
	});
var $elm$http$Http$MySub = F2(
	function (a, b) {
		return {$: 'MySub', a: a, b: b};
	});
var $elm$http$Http$subMap = F2(
	function (func, _v0) {
		var tracker = _v0.a;
		var toMsg = _v0.b;
		return A2(
			$elm$http$Http$MySub,
			tracker,
			A2($elm$core$Basics$composeR, toMsg, func));
	});
_Platform_effectManagers['Http'] = _Platform_createManager($elm$http$Http$init, $elm$http$Http$onEffects, $elm$http$Http$onSelfMsg, $elm$http$Http$cmdMap, $elm$http$Http$subMap);
var $elm$http$Http$command = _Platform_leaf('Http');
var $elm$http$Http$subscription = _Platform_leaf('Http');
var $elm$http$Http$request = function (r) {
	return $elm$http$Http$command(
		$elm$http$Http$Request(
			{allowCookiesFromOtherDomains: false, body: r.body, expect: r.expect, headers: r.headers, method: r.method, timeout: r.timeout, tracker: r.tracker, url: r.url}));
};
var $elm$core$String$toLower = _String_toLower;
var $author$project$Server$acadiaRequest = F3(
	function (headers, toMsg, _v0) {
		var enc = _v0.a;
		var dec = _v0.b;
		return $elm$http$Http$request(
			{
				body: A2(
					$elm$http$Http$bytesBody,
					'application/octet-stream',
					$elm$bytes$Bytes$Encode$encode(enc)),
				expect: A2(
					$elm$http$Http$expectBytesResponse,
					toMsg,
					$author$project$Server$bytesResponseWithHeaders(dec)),
				headers: A2(
					$elm$core$List$cons,
					A2($elm$http$Http$header, 'accept', 'application/octet-stream'),
					A2(
						$elm$core$List$filterMap,
						function (_v1) {
							var key = _v1.a;
							var value = _v1.b;
							var _v2 = $elm$core$String$toLower(key);
							switch (_v2) {
								case 'cookie':
									return $elm$core$Maybe$Just(
										A2($elm$http$Http$header, key, value));
								case 'content-type':
									return $elm$core$Maybe$Just(
										A2($elm$http$Http$header, key, value));
								default:
									return $elm$core$Maybe$Nothing;
							}
						},
						headers)),
				method: 'POST',
				timeout: $elm$core$Maybe$Nothing,
				tracker: $elm$core$Maybe$Nothing,
				url: 'http://localhost:9000/_endpoints'
			});
	});
var $author$project$Backend$AuthInfo = F2(
	function (email, password) {
		return {email: email, password: password};
	});
var $author$project$Acadia$Api$authInfoCodec = $author$project$Serialize$finishRecord(
	A3(
		$author$project$Serialize$field,
		function ($) {
			return $.password;
		},
		$author$project$Serialize$string,
		A3(
			$author$project$Serialize$field,
			function ($) {
				return $.email;
			},
			$author$project$Serialize$string,
			$author$project$Serialize$record($author$project$Backend$AuthInfo))));
var $author$project$Acadia$Transaction$Transaction = F2(
	function (a, b) {
		return {$: 'Transaction', a: a, b: b};
	});
var $author$project$Acadia$Bytes$Decode$andThen = $elm$bytes$Bytes$Decode$andThen;
var $author$project$Acadia$Bytes$Decode$fail = $elm$bytes$Bytes$Decode$fail;
var $author$project$Acadia$UInt32$UInt32 = function (a) {
	return {$: 'UInt32', a: a};
};
var $author$project$Acadia$UInt32$fromInt = function (n) {
	return $author$project$Acadia$UInt32$UInt32(n & 4294967295);
};
var $author$project$Acadia$Int32$Int32 = function (a) {
	return {$: 'Int32', a: a};
};
var $elm$bytes$Bytes$Decode$signedInt32 = function (endianness) {
	return $elm$bytes$Bytes$Decode$Decoder(
		_Bytes_read_i32(
			_Utils_eq(endianness, $elm$bytes$Bytes$LE)));
};
var $author$project$Acadia$Int32$decodeBE = A2(
	$elm$bytes$Bytes$Decode$map,
	$author$project$Acadia$Int32$Int32,
	$elm$bytes$Bytes$Decode$signedInt32($elm$bytes$Bytes$BE));
var $author$project$Acadia$Bytes$Decode$int32BE = $author$project$Acadia$Int32$decodeBE;
var $author$project$Acadia$UInt32$toInt = function (_v0) {
	var n = _v0.a;
	return n;
};
var $author$project$Acadia$Bytes$Decode$string = function (n) {
	return $elm$bytes$Bytes$Decode$string(
		$author$project$Acadia$UInt32$toInt(n));
};
var $author$project$Acadia$Int32$toInt = function (_v0) {
	var n = _v0.a;
	return n;
};
var $author$project$Backend$d_ARG_1 = A2(
	$author$project$Acadia$Bytes$Decode$andThen,
	function (n) {
		return ($author$project$Acadia$Int32$toInt(n) < 0) ? $author$project$Acadia$Bytes$Decode$fail : $author$project$Acadia$Bytes$Decode$string(
			$author$project$Acadia$UInt32$fromInt(
				$author$project$Acadia$Int32$toInt(n)));
	},
	$author$project$Acadia$Bytes$Decode$int32BE);
var $author$project$Backend$OrganizationID = function (a) {
	return {$: 'OrganizationID', a: a};
};
var $author$project$Acadia$Bytes$Decode$map = $elm$bytes$Bytes$Decode$map;
var $elm$core$Basics$neq = _Utils_notEqual;
var $author$project$Acadia$Uuid$Uuid = F4(
	function (a, b, c, d) {
		return {$: 'Uuid', a: a, b: b, c: c, d: d};
	});
var $elm$bytes$Bytes$Decode$map4 = F5(
	function (func, _v0, _v1, _v2, _v3) {
		var decodeA = _v0.a;
		var decodeB = _v1.a;
		var decodeC = _v2.a;
		var decodeD = _v3.a;
		return $elm$bytes$Bytes$Decode$Decoder(
			F2(
				function (bites, offset) {
					var _v4 = A2(decodeA, bites, offset);
					var aOffset = _v4.a;
					var a = _v4.b;
					var _v5 = A2(decodeB, bites, aOffset);
					var bOffset = _v5.a;
					var b = _v5.b;
					var _v6 = A2(decodeC, bites, bOffset);
					var cOffset = _v6.a;
					var c = _v6.b;
					var _v7 = A2(decodeD, bites, cOffset);
					var dOffset = _v7.a;
					var d = _v7.b;
					return _Utils_Tuple2(
						dOffset,
						A4(func, a, b, c, d));
				}));
	});
var $author$project$Acadia$Uuid$decode = A5(
	$elm$bytes$Bytes$Decode$map4,
	$author$project$Acadia$Uuid$Uuid,
	$elm$bytes$Bytes$Decode$unsignedInt32($elm$bytes$Bytes$BE),
	$elm$bytes$Bytes$Decode$unsignedInt32($elm$bytes$Bytes$BE),
	$elm$bytes$Bytes$Decode$unsignedInt32($elm$bytes$Bytes$BE),
	$elm$bytes$Bytes$Decode$unsignedInt32($elm$bytes$Bytes$BE));
var $author$project$Acadia$Bytes$Decode$uuid = $author$project$Acadia$Uuid$decode;
var $author$project$Backend$d_ARG_4 = A2(
	$author$project$Acadia$Bytes$Decode$map,
	function (v) {
		return $author$project$Backend$OrganizationID(v);
	},
	A2(
		$author$project$Acadia$Bytes$Decode$andThen,
		function (n) {
			return ($author$project$Acadia$Int32$toInt(n) !== 16) ? $author$project$Acadia$Bytes$Decode$fail : $author$project$Acadia$Bytes$Decode$uuid;
		},
		$author$project$Acadia$Bytes$Decode$int32BE));
var $author$project$Acadia$Bytes$Encode$getSizeString = function (str) {
	return $author$project$Acadia$UInt32$fromInt(
		$elm$bytes$Bytes$Encode$getStringWidth(str));
};
var $author$project$Acadia$Bytes$Encode$sequence = $elm$bytes$Bytes$Encode$sequence;
var $author$project$Acadia$Bytes$Encode$string = $elm$bytes$Bytes$Encode$string;
var $author$project$Acadia$UInt32$encodeBE = function (_v0) {
	var n = _v0.a;
	return A2($elm$bytes$Bytes$Encode$unsignedInt32, $elm$bytes$Bytes$BE, n);
};
var $author$project$Acadia$Bytes$Encode$uint32BE = $author$project$Acadia$UInt32$encodeBE;
var $author$project$Backend$e_ARG_3 = function (v) {
	var v_name = v.name;
	var o0 = $author$project$Acadia$UInt32$fromInt(0);
	var o1 = $author$project$Acadia$UInt32$fromInt(
		$author$project$Acadia$UInt32$toInt(o0) + $author$project$Acadia$UInt32$toInt(
			$author$project$Acadia$Bytes$Encode$getSizeString(v_name)));
	var e0 = $author$project$Acadia$Bytes$Encode$string(v_name);
	return $author$project$Acadia$Bytes$Encode$sequence(
		_List_fromArray(
			[
				$author$project$Acadia$Bytes$Encode$uint32BE(o1),
				e0
			]));
};
var $author$project$Acadia$Bytes$Decode$succeed = $elm$bytes$Bytes$Decode$succeed;
var $author$project$Backend$createOrganization = function (v0) {
	return A2(
		$author$project$Acadia$Transaction$Transaction,
		$author$project$Acadia$Bytes$Encode$sequence(
			_List_fromArray(
				[
					$author$project$Acadia$Bytes$Encode$uint32BE(
					$author$project$Acadia$UInt32$fromInt(0)),
					$author$project$Acadia$Bytes$Encode$uint32BE(
					$author$project$Acadia$UInt32$fromInt(6)),
					$author$project$Backend$e_ARG_3(v0)
				])),
		A2(
			$author$project$Acadia$Bytes$Decode$andThen,
			function (id) {
				return A2(
					$author$project$Acadia$Bytes$Decode$andThen,
					function (name) {
						return $author$project$Acadia$Bytes$Decode$succeed(
							{id: id, name: name});
					},
					$author$project$Backend$d_ARG_1);
			},
			$author$project$Backend$d_ARG_4));
};
var $author$project$Acadia$Api$createOrganizationCodec = $author$project$Serialize$finishRecord(
	A3(
		$author$project$Serialize$field,
		function ($) {
			return $.name;
		},
		$author$project$Serialize$string,
		$author$project$Serialize$record(
			function (name) {
				return {name: name};
			})));
var $elm$core$String$length = _String_length;
var $elm$core$Basics$modBy = _Basics_modBy;
var $elm$core$Bitwise$shiftRightBy = _Bitwise_shiftRightBy;
var $elm$core$String$repeatHelp = F3(
	function (n, chunk, result) {
		return (n <= 0) ? result : A3(
			$elm$core$String$repeatHelp,
			n >> 1,
			_Utils_ap(chunk, chunk),
			(!(n & 1)) ? result : _Utils_ap(result, chunk));
	});
var $elm$core$String$repeat = F2(
	function (n, chunk) {
		return A3($elm$core$String$repeatHelp, n, chunk, '');
	});
var $author$project$Serialize$replaceFromUrl = A2(
	$elm$core$Maybe$withDefault,
	$elm$regex$Regex$never,
	$elm$regex$Regex$fromString('[-_]'));
var $elm$core$String$slice = _String_slice;
var $elm$core$String$dropLeft = F2(
	function (n, string) {
		return (n < 1) ? string : A3(
			$elm$core$String$slice,
			n,
			$elm$core$String$length(string),
			string);
	});
var $danfishgold$base64_bytes$Encode$isValidChar = function (c) {
	if ($elm$core$Char$isAlphaNum(c)) {
		return true;
	} else {
		switch (c.valueOf()) {
			case '+':
				return true;
			case '/':
				return true;
			default:
				return false;
		}
	}
};
var $elm$core$Basics$negate = function (n) {
	return -n;
};
var $danfishgold$base64_bytes$Encode$unsafeConvertChar = function (_char) {
	var key = $elm$core$Char$toCode(_char);
	if ((key >= 65) && (key <= 90)) {
		return key - 65;
	} else {
		if ((key >= 97) && (key <= 122)) {
			return (key - 97) + 26;
		} else {
			if ((key >= 48) && (key <= 57)) {
				return ((key - 48) + 26) + 26;
			} else {
				switch (_char.valueOf()) {
					case '+':
						return 62;
					case '/':
						return 63;
					default:
						return -1;
				}
			}
		}
	}
};
var $elm$bytes$Bytes$Encode$U8 = function (a) {
	return {$: 'U8', a: a};
};
var $elm$bytes$Bytes$Encode$unsignedInt8 = $elm$bytes$Bytes$Encode$U8;
var $danfishgold$base64_bytes$Encode$encodeCharacters = F4(
	function (a, b, c, d) {
		if ($danfishgold$base64_bytes$Encode$isValidChar(a) && $danfishgold$base64_bytes$Encode$isValidChar(b)) {
			var n2 = $danfishgold$base64_bytes$Encode$unsafeConvertChar(b);
			var n1 = $danfishgold$base64_bytes$Encode$unsafeConvertChar(a);
			if ('=' === d.valueOf()) {
				if ('=' === c.valueOf()) {
					var n = (n1 << 18) | (n2 << 12);
					var b1 = n >> 16;
					return $elm$core$Maybe$Just(
						$elm$bytes$Bytes$Encode$unsignedInt8(b1));
				} else {
					if ($danfishgold$base64_bytes$Encode$isValidChar(c)) {
						var n3 = $danfishgold$base64_bytes$Encode$unsafeConvertChar(c);
						var n = ((n1 << 18) | (n2 << 12)) | (n3 << 6);
						var combined = n >> 8;
						return $elm$core$Maybe$Just(
							A2($elm$bytes$Bytes$Encode$unsignedInt16, $elm$bytes$Bytes$BE, combined));
					} else {
						return $elm$core$Maybe$Nothing;
					}
				}
			} else {
				if ($danfishgold$base64_bytes$Encode$isValidChar(c) && $danfishgold$base64_bytes$Encode$isValidChar(d)) {
					var n4 = $danfishgold$base64_bytes$Encode$unsafeConvertChar(d);
					var n3 = $danfishgold$base64_bytes$Encode$unsafeConvertChar(c);
					var n = ((n1 << 18) | (n2 << 12)) | ((n3 << 6) | n4);
					var combined = n >> 8;
					var b3 = n;
					return $elm$core$Maybe$Just(
						$elm$bytes$Bytes$Encode$sequence(
							_List_fromArray(
								[
									A2($elm$bytes$Bytes$Encode$unsignedInt16, $elm$bytes$Bytes$BE, combined),
									$elm$bytes$Bytes$Encode$unsignedInt8(b3)
								])));
				} else {
					return $elm$core$Maybe$Nothing;
				}
			}
		} else {
			return $elm$core$Maybe$Nothing;
		}
	});
var $elm$core$String$left = F2(
	function (n, string) {
		return (n < 1) ? '' : A3($elm$core$String$slice, 0, n, string);
	});
var $elm$core$String$foldr = _String_foldr;
var $elm$core$String$toList = function (string) {
	return A3($elm$core$String$foldr, $elm$core$List$cons, _List_Nil, string);
};
var $danfishgold$base64_bytes$Encode$encodeChunks = F2(
	function (input, accum) {
		encodeChunks:
		while (true) {
			var _v0 = $elm$core$String$toList(
				A2($elm$core$String$left, 4, input));
			_v0$4:
			while (true) {
				if (!_v0.b) {
					return $elm$core$Maybe$Just(accum);
				} else {
					if (_v0.b.b) {
						if (_v0.b.b.b) {
							if (_v0.b.b.b.b) {
								if (!_v0.b.b.b.b.b) {
									var a = _v0.a;
									var _v1 = _v0.b;
									var b = _v1.a;
									var _v2 = _v1.b;
									var c = _v2.a;
									var _v3 = _v2.b;
									var d = _v3.a;
									var _v4 = A4($danfishgold$base64_bytes$Encode$encodeCharacters, a, b, c, d);
									if (_v4.$ === 'Just') {
										var enc = _v4.a;
										var $temp$input = A2($elm$core$String$dropLeft, 4, input),
											$temp$accum = A2($elm$core$List$cons, enc, accum);
										input = $temp$input;
										accum = $temp$accum;
										continue encodeChunks;
									} else {
										return $elm$core$Maybe$Nothing;
									}
								} else {
									break _v0$4;
								}
							} else {
								var a = _v0.a;
								var _v5 = _v0.b;
								var b = _v5.a;
								var _v6 = _v5.b;
								var c = _v6.a;
								var _v7 = A4(
									$danfishgold$base64_bytes$Encode$encodeCharacters,
									a,
									b,
									c,
									_Utils_chr('='));
								if (_v7.$ === 'Nothing') {
									return $elm$core$Maybe$Nothing;
								} else {
									var enc = _v7.a;
									return $elm$core$Maybe$Just(
										A2($elm$core$List$cons, enc, accum));
								}
							}
						} else {
							var a = _v0.a;
							var _v8 = _v0.b;
							var b = _v8.a;
							var _v9 = A4(
								$danfishgold$base64_bytes$Encode$encodeCharacters,
								a,
								b,
								_Utils_chr('='),
								_Utils_chr('='));
							if (_v9.$ === 'Nothing') {
								return $elm$core$Maybe$Nothing;
							} else {
								var enc = _v9.a;
								return $elm$core$Maybe$Just(
									A2($elm$core$List$cons, enc, accum));
							}
						}
					} else {
						break _v0$4;
					}
				}
			}
			return $elm$core$Maybe$Nothing;
		}
	});
var $elm$core$Maybe$map = F2(
	function (f, maybe) {
		if (maybe.$ === 'Just') {
			var value = maybe.a;
			return $elm$core$Maybe$Just(
				f(value));
		} else {
			return $elm$core$Maybe$Nothing;
		}
	});
var $danfishgold$base64_bytes$Encode$encoder = function (string) {
	return A2(
		$elm$core$Maybe$map,
		A2($elm$core$Basics$composeR, $elm$core$List$reverse, $elm$bytes$Bytes$Encode$sequence),
		A2($danfishgold$base64_bytes$Encode$encodeChunks, string, _List_Nil));
};
var $danfishgold$base64_bytes$Encode$toBytes = function (string) {
	return A2(
		$elm$core$Maybe$map,
		$elm$bytes$Bytes$Encode$encode,
		$danfishgold$base64_bytes$Encode$encoder(string));
};
var $danfishgold$base64_bytes$Base64$toBytes = $danfishgold$base64_bytes$Encode$toBytes;
var $author$project$Serialize$decode = function (base64text) {
	var strlen = $elm$core$String$length(base64text);
	var replaceChar = function (rematch) {
		var _v0 = rematch.match;
		if (_v0 === '-') {
			return '+';
		} else {
			return '/';
		}
	};
	if (!strlen) {
		return $elm$core$Maybe$Just(
			$elm$bytes$Bytes$Encode$encode(
				$elm$bytes$Bytes$Encode$sequence(_List_Nil)));
	} else {
		var hanging = A2($elm$core$Basics$modBy, 4, strlen);
		var ilen = (!hanging) ? 0 : (4 - hanging);
		return $danfishgold$base64_bytes$Base64$toBytes(
			A3(
				$elm$regex$Regex$replace,
				$author$project$Serialize$replaceFromUrl,
				replaceChar,
				_Utils_ap(
					base64text,
					A2($elm$core$String$repeat, ilen, '='))));
	}
};
var $author$project$Serialize$decodeFromBytes = F2(
	function (codec, bytes_) {
		var decoder = $author$project$Serialize$toBytesDecoder(codec);
		return A2($elm$bytes$Bytes$Decode$decode, decoder, bytes_);
	});
var $author$project$Serialize$decodeFromString = F2(
	function (codec, base64) {
		var _v0 = $author$project$Serialize$decode(base64);
		if (_v0.$ === 'Just') {
			var bytes_ = _v0.a;
			return A2($author$project$Serialize$decodeFromBytes, codec, bytes_);
		} else {
			return $elm$core$Maybe$Nothing;
		}
	});
var $elm$json$Json$Decode$decodeValue = _Json_run;
var $author$project$Endpoints$ApiAuthLogin = {$: 'ApiAuthLogin'};
var $author$project$Endpoints$ApiAuthLogout = {$: 'ApiAuthLogout'};
var $author$project$Endpoints$ApiAuthSelf = {$: 'ApiAuthSelf'};
var $author$project$Endpoints$ApiAuthSignup = {$: 'ApiAuthSignup'};
var $author$project$Endpoints$ApiOrganizations = {$: 'ApiOrganizations'};
var $author$project$Endpoints$fromString = function (str) {
	switch (str) {
		case '/api/auth/login':
			return $elm$core$Maybe$Just($author$project$Endpoints$ApiAuthLogin);
		case '/api/auth/signup':
			return $elm$core$Maybe$Just($author$project$Endpoints$ApiAuthSignup);
		case '/api/auth/logout':
			return $elm$core$Maybe$Just($author$project$Endpoints$ApiAuthLogout);
		case '/api/auth/self':
			return $elm$core$Maybe$Just($author$project$Endpoints$ApiAuthSelf);
		case '/api/organizations':
			return $elm$core$Maybe$Just($author$project$Endpoints$ApiOrganizations);
		default:
			return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Backend$UserID = function (a) {
	return {$: 'UserID', a: a};
};
var $author$project$Backend$d_ARG_2 = A2(
	$author$project$Acadia$Bytes$Decode$andThen,
	function (n) {
		return ($author$project$Acadia$Int32$toInt(n) < 16) ? $author$project$Acadia$Bytes$Decode$fail : A2(
			$author$project$Acadia$Bytes$Decode$andThen,
			function (x_id_0) {
				var o0 = $author$project$Acadia$UInt32$fromInt(16);
				return A2(
					$author$project$Acadia$Bytes$Decode$andThen,
					function (x_primaryEmail) {
						return $author$project$Acadia$Bytes$Decode$succeed(
							{
								id: $author$project$Backend$UserID(x_id_0),
								primaryEmail: x_primaryEmail
							});
					},
					$author$project$Acadia$Bytes$Decode$string(
						$author$project$Acadia$UInt32$fromInt(
							$author$project$Acadia$UInt32$toInt(
								$author$project$Acadia$UInt32$fromInt(
									$author$project$Acadia$Int32$toInt(n))) - $author$project$Acadia$UInt32$toInt(o0))));
			},
			$author$project$Acadia$Bytes$Decode$uuid);
	},
	$author$project$Acadia$Bytes$Decode$int32BE);
var $author$project$Acadia$UInt8$toInt = function (_v0) {
	var n = _v0.a;
	return n;
};
var $author$project$Acadia$UInt8$UInt8 = function (a) {
	return {$: 'UInt8', a: a};
};
var $author$project$Acadia$UInt8$decode = A2($elm$bytes$Bytes$Decode$map, $author$project$Acadia$UInt8$UInt8, $elm$bytes$Bytes$Decode$unsignedInt8);
var $author$project$Acadia$Bytes$Decode$uint8 = $author$project$Acadia$UInt8$decode;
var $author$project$Backend$d_VARIANT_0 = function (size) {
	return A2(
		$author$project$Acadia$Bytes$Decode$andThen,
		function (tag) {
			var _v0 = $author$project$Acadia$UInt8$toInt(tag);
			switch (_v0) {
				case 0:
					return ($author$project$Acadia$UInt32$toInt(size) < 17) ? $author$project$Acadia$Bytes$Decode$fail : A2(
						$author$project$Acadia$Bytes$Decode$andThen,
						function (x_0_id_0) {
							var o0 = $author$project$Acadia$UInt32$fromInt(17);
							return A2(
								$author$project$Acadia$Bytes$Decode$andThen,
								function (x_0_name) {
									return $author$project$Acadia$Bytes$Decode$succeed(
										$elm$core$Maybe$Just(
											{
												id: $author$project$Backend$OrganizationID(x_0_id_0),
												name: x_0_name
											}));
								},
								$author$project$Acadia$Bytes$Decode$string(
									$author$project$Acadia$UInt32$fromInt(
										$author$project$Acadia$UInt32$toInt(size) - $author$project$Acadia$UInt32$toInt(o0))));
						},
						$author$project$Acadia$Bytes$Decode$uuid);
				case 1:
					return ($author$project$Acadia$UInt32$toInt(size) !== 1) ? $author$project$Acadia$Bytes$Decode$fail : $author$project$Acadia$Bytes$Decode$succeed($elm$core$Maybe$Nothing);
				default:
					return $author$project$Acadia$Bytes$Decode$fail;
			}
		},
		$author$project$Acadia$Bytes$Decode$uint8);
};
var $author$project$Backend$d_ARG_3 = A2(
	$author$project$Acadia$Bytes$Decode$andThen,
	function (n) {
		return ($author$project$Acadia$Int32$toInt(n) < 1) ? $author$project$Acadia$Bytes$Decode$fail : $author$project$Backend$d_VARIANT_0(
			$author$project$Acadia$UInt32$fromInt(
				$author$project$Acadia$Int32$toInt(n)));
	},
	$author$project$Acadia$Bytes$Decode$int32BE);
var $author$project$Acadia$Bytes$Decode$map2 = $elm$bytes$Bytes$Decode$map2;
var $author$project$Backend$getUserSelf = A2(
	$author$project$Acadia$Transaction$Transaction,
	$author$project$Acadia$Bytes$Encode$sequence(
		_List_fromArray(
			[
				$author$project$Acadia$Bytes$Encode$uint32BE(
				$author$project$Acadia$UInt32$fromInt(0)),
				$author$project$Acadia$Bytes$Encode$uint32BE(
				$author$project$Acadia$UInt32$fromInt(5))
			])),
	A3(
		$author$project$Acadia$Bytes$Decode$map2,
		F2(
			function (a, b) {
				return _Utils_Tuple2(a, b);
			}),
		$author$project$Backend$d_ARG_2,
		$author$project$Backend$d_ARG_3));
var $author$project$Serialize$variant0 = function (ctor) {
	return A2(
		$author$project$Serialize$variant,
		function (c) {
			return c(_List_Nil);
		},
		$elm$bytes$Bytes$Decode$succeed(ctor));
};
var $author$project$Serialize$maybe = function (justCodec) {
	return $author$project$Serialize$finishCustomType(
		A3(
			$author$project$Serialize$variant1,
			$elm$core$Maybe$Just,
			justCodec,
			A2(
				$author$project$Serialize$variant0,
				$elm$core$Maybe$Nothing,
				$author$project$Serialize$customType(
					F3(
						function (nothingEncoder, justEncoder, value) {
							if (value.$ === 'Nothing') {
								return nothingEncoder;
							} else {
								var value_ = value.a;
								return justEncoder(value_);
							}
						})))));
};
var $author$project$Backend$Organization = F2(
	function (id, name) {
		return {id: id, name: name};
	});
var $author$project$Acadia$Uuid$encode = function (_v0) {
	var a = _v0.a;
	var b = _v0.b;
	var c = _v0.c;
	var d = _v0.d;
	return $elm$bytes$Bytes$Encode$sequence(
		_List_fromArray(
			[
				A2($elm$bytes$Bytes$Encode$unsignedInt32, $elm$bytes$Bytes$BE, a),
				A2($elm$bytes$Bytes$Encode$unsignedInt32, $elm$bytes$Bytes$BE, b),
				A2($elm$bytes$Bytes$Encode$unsignedInt32, $elm$bytes$Bytes$BE, c),
				A2($elm$bytes$Bytes$Encode$unsignedInt32, $elm$bytes$Bytes$BE, d)
			]));
};
var $author$project$Serialize$uuid = A2($author$project$Serialize$build, $author$project$Acadia$Uuid$encode, $author$project$Acadia$Uuid$decode);
var $author$project$Acadia$Api$organizationIdCodec = $author$project$Serialize$finishCustomType(
	A3(
		$author$project$Serialize$variant1,
		$author$project$Backend$OrganizationID,
		$author$project$Serialize$uuid,
		$author$project$Serialize$customType(
			F2(
				function (enc, _v0) {
					var val = _v0.a;
					return enc(val);
				}))));
var $author$project$Acadia$Api$organizationCodec = $author$project$Serialize$finishRecord(
	A3(
		$author$project$Serialize$field,
		function ($) {
			return $.name;
		},
		$author$project$Serialize$string,
		A3(
			$author$project$Serialize$field,
			function ($) {
				return $.id;
			},
			$author$project$Acadia$Api$organizationIdCodec,
			$author$project$Serialize$record($author$project$Backend$Organization))));
var $elm$core$Tuple$pair = F2(
	function (a, b) {
		return _Utils_Tuple2(a, b);
	});
var $elm$core$Tuple$second = function (_v0) {
	var y = _v0.b;
	return y;
};
var $author$project$Serialize$tuple = F2(
	function (codecFirst, codecSecond) {
		return $author$project$Serialize$finishRecord(
			A3(
				$author$project$Serialize$field,
				$elm$core$Tuple$second,
				codecSecond,
				A3(
					$author$project$Serialize$field,
					$elm$core$Tuple$first,
					codecFirst,
					$author$project$Serialize$record($elm$core$Tuple$pair))));
	});
var $author$project$Backend$User = F2(
	function (id, primaryEmail) {
		return {id: id, primaryEmail: primaryEmail};
	});
var $author$project$Acadia$Api$userIdCodec = $author$project$Serialize$finishCustomType(
	A3(
		$author$project$Serialize$variant1,
		$author$project$Backend$UserID,
		$author$project$Serialize$uuid,
		$author$project$Serialize$customType(
			F2(
				function (enc, _v0) {
					var val = _v0.a;
					return enc(val);
				}))));
var $author$project$Acadia$Api$userCodec = $author$project$Serialize$finishRecord(
	A3(
		$author$project$Serialize$field,
		function ($) {
			return $.primaryEmail;
		},
		$author$project$Serialize$string,
		A3(
			$author$project$Serialize$field,
			function ($) {
				return $.id;
			},
			$author$project$Acadia$Api$userIdCodec,
			$author$project$Serialize$record($author$project$Backend$User))));
var $author$project$Acadia$Api$getUserSelfCodec = A2(
	$author$project$Serialize$tuple,
	$author$project$Acadia$Api$userCodec,
	$author$project$Serialize$maybe($author$project$Acadia$Api$organizationCodec));
var $author$project$Acadia$UInt32$encodeLE = function (_v0) {
	var n = _v0.a;
	return A2($elm$bytes$Bytes$Encode$unsignedInt32, $elm$bytes$Bytes$LE, n);
};
var $author$project$Acadia$Bytes$Encode$uint32LE = $author$project$Acadia$UInt32$encodeLE;
var $author$project$Backend$e_ARG_0 = function (v) {
	var v_password = v.password;
	var v_email = v.email;
	var o0 = $author$project$Acadia$UInt32$fromInt(4);
	var o1 = $author$project$Acadia$UInt32$fromInt(
		$author$project$Acadia$UInt32$toInt(o0) + $author$project$Acadia$UInt32$toInt(
			$author$project$Acadia$Bytes$Encode$getSizeString(v_email)));
	var o2 = $author$project$Acadia$UInt32$fromInt(
		$author$project$Acadia$UInt32$toInt(o1) + $author$project$Acadia$UInt32$toInt(
			$author$project$Acadia$Bytes$Encode$getSizeString(v_password)));
	var e1 = $author$project$Acadia$Bytes$Encode$string(v_password);
	var e0 = $author$project$Acadia$Bytes$Encode$string(v_email);
	return $author$project$Acadia$Bytes$Encode$sequence(
		_List_fromArray(
			[
				$author$project$Acadia$Bytes$Encode$uint32BE(o2),
				$author$project$Acadia$Bytes$Encode$uint32LE(o1),
				e0,
				e1
			]));
};
var $author$project$Backend$login = function (v0) {
	return A2(
		$author$project$Acadia$Transaction$Transaction,
		$author$project$Acadia$Bytes$Encode$sequence(
			_List_fromArray(
				[
					$author$project$Acadia$Bytes$Encode$uint32BE(
					$author$project$Acadia$UInt32$fromInt(0)),
					$author$project$Acadia$Bytes$Encode$uint32BE(
					$author$project$Acadia$UInt32$fromInt(0)),
					$author$project$Backend$e_ARG_0(v0)
				])),
		$author$project$Acadia$Bytes$Decode$succeed(_Utils_Tuple0));
};
var $elm$core$Basics$always = F2(
	function (a, _v0) {
		return a;
	});
var $author$project$Serialize$unit = A2(
	$author$project$Serialize$build,
	$elm$core$Basics$always(
		$elm$bytes$Bytes$Encode$sequence(_List_Nil)),
	$elm$bytes$Bytes$Decode$succeed(_Utils_Tuple0));
var $author$project$Acadia$Api$loginCodec = $author$project$Serialize$unit;
var $author$project$Backend$logout = A2(
	$author$project$Acadia$Transaction$Transaction,
	$author$project$Acadia$Bytes$Encode$sequence(
		_List_fromArray(
			[
				$author$project$Acadia$Bytes$Encode$uint32BE(
				$author$project$Acadia$UInt32$fromInt(0)),
				$author$project$Acadia$Bytes$Encode$uint32BE(
				$author$project$Acadia$UInt32$fromInt(1))
			])),
	$author$project$Acadia$Bytes$Decode$succeed(_Utils_Tuple0));
var $author$project$Acadia$Api$logoutCodec = $author$project$Serialize$unit;
var $author$project$Http$Extended$Request = F4(
	function (path, method, headers, body) {
		return {body: body, headers: headers, method: method, path: path};
	});
var $elm$json$Json$Decode$andThen = _Json_andThen;
var $elm$json$Json$Decode$fail = _Json_fail;
var $elm$json$Json$Decode$field = _Json_decodeField;
var $author$project$Http$Method$Connect = {$: 'Connect'};
var $author$project$Http$Method$Delete = {$: 'Delete'};
var $author$project$Http$Method$Get = {$: 'Get'};
var $author$project$Http$Method$Head = {$: 'Head'};
var $author$project$Http$Method$Options = {$: 'Options'};
var $author$project$Http$Method$Patch = {$: 'Patch'};
var $author$project$Http$Method$Put = {$: 'Put'};
var $author$project$Http$Method$Trace = {$: 'Trace'};
var $author$project$Http$Method$fromString = function (str) {
	switch (str) {
		case 'GET':
			return $elm$core$Maybe$Just($author$project$Http$Method$Get);
		case 'HEAD':
			return $elm$core$Maybe$Just($author$project$Http$Method$Head);
		case 'POST':
			return $elm$core$Maybe$Just($author$project$Http$Method$Post);
		case 'PUT':
			return $elm$core$Maybe$Just($author$project$Http$Method$Put);
		case 'DELETE':
			return $elm$core$Maybe$Just($author$project$Http$Method$Delete);
		case 'CONNECT':
			return $elm$core$Maybe$Just($author$project$Http$Method$Connect);
		case 'OPTIONS':
			return $elm$core$Maybe$Just($author$project$Http$Method$Options);
		case 'TRACE':
			return $elm$core$Maybe$Just($author$project$Http$Method$Trace);
		case 'PATCH':
			return $elm$core$Maybe$Just($author$project$Http$Method$Patch);
		default:
			return $elm$core$Maybe$Nothing;
	}
};
var $elm$json$Json$Decode$list = _Json_decodeList;
var $elm$json$Json$Decode$map4 = _Json_map4;
var $elm$json$Json$Decode$string = _Json_decodeString;
var $elm$json$Json$Decode$succeed = _Json_succeed;
var $author$project$Http$Extended$requestDecode = A5(
	$elm$json$Json$Decode$map4,
	$author$project$Http$Extended$Request,
	A2($elm$json$Json$Decode$field, 'path', $elm$json$Json$Decode$string),
	A2(
		$elm$json$Json$Decode$field,
		'method',
		A2(
			$elm$json$Json$Decode$andThen,
			function (methodStr) {
				var _v0 = $author$project$Http$Method$fromString(methodStr);
				if (_v0.$ === 'Just') {
					var method = _v0.a;
					return $elm$json$Json$Decode$succeed(method);
				} else {
					return $elm$json$Json$Decode$fail('Unknown method: ' + methodStr);
				}
			},
			$elm$json$Json$Decode$string)),
	A2(
		$elm$json$Json$Decode$field,
		'headers',
		$elm$json$Json$Decode$list(
			A2(
				$elm$json$Json$Decode$andThen,
				function (vals) {
					if ((vals.b && vals.b.b) && (!vals.b.b.b)) {
						var key = vals.a;
						var _v2 = vals.b;
						var value = _v2.a;
						return $elm$json$Json$Decode$succeed(
							_Utils_Tuple2(key, value));
					} else {
						return $elm$json$Json$Decode$fail('Invalid header');
					}
				},
				$elm$json$Json$Decode$list($elm$json$Json$Decode$string)))),
	A2($elm$json$Json$Decode$field, 'body', $elm$json$Json$Decode$string));
var $author$project$Backend$SignUpInfo = F3(
	function (name, email, password) {
		return {email: email, name: name, password: password};
	});
var $author$project$Acadia$Api$signUpInfoCodec = $author$project$Serialize$finishRecord(
	A3(
		$author$project$Serialize$field,
		function ($) {
			return $.password;
		},
		$author$project$Serialize$string,
		A3(
			$author$project$Serialize$field,
			function ($) {
				return $.email;
			},
			$author$project$Serialize$string,
			A3(
				$author$project$Serialize$field,
				function ($) {
					return $.name;
				},
				$author$project$Serialize$string,
				$author$project$Serialize$record($author$project$Backend$SignUpInfo)))));
var $author$project$Backend$e_ARG_1 = function (v) {
	var v_password = v.password;
	var v_name = v.name;
	var v_email = v.email;
	var o0 = $author$project$Acadia$UInt32$fromInt(8);
	var o1 = $author$project$Acadia$UInt32$fromInt(
		$author$project$Acadia$UInt32$toInt(o0) + $author$project$Acadia$UInt32$toInt(
			$author$project$Acadia$Bytes$Encode$getSizeString(v_name)));
	var o2 = $author$project$Acadia$UInt32$fromInt(
		$author$project$Acadia$UInt32$toInt(o1) + $author$project$Acadia$UInt32$toInt(
			$author$project$Acadia$Bytes$Encode$getSizeString(v_email)));
	var o3 = $author$project$Acadia$UInt32$fromInt(
		$author$project$Acadia$UInt32$toInt(o2) + $author$project$Acadia$UInt32$toInt(
			$author$project$Acadia$Bytes$Encode$getSizeString(v_password)));
	var e2 = $author$project$Acadia$Bytes$Encode$string(v_password);
	var e1 = $author$project$Acadia$Bytes$Encode$string(v_email);
	var e0 = $author$project$Acadia$Bytes$Encode$string(v_name);
	return $author$project$Acadia$Bytes$Encode$sequence(
		_List_fromArray(
			[
				$author$project$Acadia$Bytes$Encode$uint32BE(o3),
				$author$project$Acadia$Bytes$Encode$uint32LE(o1),
				$author$project$Acadia$Bytes$Encode$uint32LE(o2),
				e0,
				e1,
				e2
			]));
};
var $author$project$Backend$signup = function (v0) {
	return A2(
		$author$project$Acadia$Transaction$Transaction,
		$author$project$Acadia$Bytes$Encode$sequence(
			_List_fromArray(
				[
					$author$project$Acadia$Bytes$Encode$uint32BE(
					$author$project$Acadia$UInt32$fromInt(0)),
					$author$project$Acadia$Bytes$Encode$uint32BE(
					$author$project$Acadia$UInt32$fromInt(2)),
					$author$project$Backend$e_ARG_1(v0)
				])),
		$author$project$Acadia$Bytes$Decode$succeed(_Utils_Tuple0));
};
var $author$project$Server$init = function (requestJson) {
	return _Utils_Tuple2(
		{},
		function () {
			var _v0 = A2(
				$elm$core$Debug$log,
				'req dec',
				A2($elm$json$Json$Decode$decodeValue, $author$project$Http$Extended$requestDecode, requestJson));
			if (_v0.$ === 'Err') {
				return $author$project$Server$respond(
					{body: 'Not Found', headers: _List_Nil, status: $author$project$Http$Status$NotFound});
			} else {
				var request = _v0.a;
				if (!_Utils_eq(request.method, $author$project$Http$Method$Post)) {
					return $author$project$Server$respond(
						{body: 'Not Found', headers: _List_Nil, status: $author$project$Http$Status$NotFound});
				} else {
					var _v1 = $author$project$Endpoints$fromString(request.path);
					if (_v1.$ === 'Nothing') {
						return $author$project$Server$acadiaFailureResponse(
							{
								error: $author$project$Http$Extended$Generic('Not Found'),
								status: $author$project$Http$Status$NotFound
							});
					} else {
						switch (_v1.a.$) {
							case 'ApiAuthSelf':
								var _v2 = _v1.a;
								return A3(
									$author$project$Server$acadiaRequest,
									request.headers,
									$author$project$Server$AuthSelfResponse($author$project$Acadia$Api$getUserSelfCodec),
									$author$project$Backend$getUserSelf);
							case 'ApiAuthLogout':
								var _v3 = _v1.a;
								return A3(
									$author$project$Server$acadiaRequest,
									request.headers,
									$author$project$Server$AuthLogoutResponse($author$project$Acadia$Api$logoutCodec),
									$author$project$Backend$logout);
							case 'ApiAuthLogin':
								var _v4 = _v1.a;
								var _v5 = A2($author$project$Serialize$decodeFromString, $author$project$Acadia$Api$authInfoCodec, request.body);
								if (_v5.$ === 'Nothing') {
									return $author$project$Server$acadiaFailureResponse(
										{
											error: $author$project$Http$Extended$Generic('Server error'),
											status: $author$project$Http$Status$BadRequest
										});
								} else {
									var loginInfo = _v5.a;
									return ($elm$core$String$length(loginInfo.email) < 3) ? $author$project$Server$acadiaFailureResponse(
										{
											error: $author$project$Http$Extended$Field(
												{message: 'Too short', name: 'email'}),
											status: $author$project$Http$Status$BadRequest
										}) : (($elm$core$String$length(loginInfo.password) < 8) ? $author$project$Server$acadiaFailureResponse(
										{
											error: $author$project$Http$Extended$Field(
												{message: 'Too short', name: 'password'}),
											status: $author$project$Http$Status$BadRequest
										}) : A3(
										$author$project$Server$acadiaRequest,
										request.headers,
										$author$project$Server$LoginResponse($author$project$Acadia$Api$loginCodec),
										$author$project$Backend$login(loginInfo)));
								}
							case 'ApiAuthSignup':
								var _v6 = _v1.a;
								var _v7 = A2($author$project$Serialize$decodeFromString, $author$project$Acadia$Api$signUpInfoCodec, request.body);
								if (_v7.$ === 'Nothing') {
									return $author$project$Server$acadiaFailureResponse(
										{
											error: $author$project$Http$Extended$Generic('Server error'),
											status: $author$project$Http$Status$BadRequest
										});
								} else {
									var signupInfo = _v7.a;
									return ($elm$core$String$length(signupInfo.email) < 3) ? $author$project$Server$acadiaFailureResponse(
										{
											error: $author$project$Http$Extended$Field(
												{message: 'Too short', name: 'email'}),
											status: $author$project$Http$Status$BadRequest
										}) : (($elm$core$String$length(signupInfo.password) < 8) ? $author$project$Server$acadiaFailureResponse(
										{
											error: $author$project$Http$Extended$Field(
												{message: 'Too short', name: 'password'}),
											status: $author$project$Http$Status$BadRequest
										}) : (($elm$core$String$length(signupInfo.name) < 1) ? $author$project$Server$acadiaFailureResponse(
										{
											error: $author$project$Http$Extended$Field(
												{message: 'Too short', name: 'name'}),
											status: $author$project$Http$Status$BadRequest
										}) : A3(
										$author$project$Server$acadiaRequest,
										request.headers,
										$author$project$Server$LoginResponse($author$project$Acadia$Api$loginCodec),
										$author$project$Backend$signup(signupInfo))));
								}
							default:
								var _v8 = _v1.a;
								var _v9 = A2($author$project$Serialize$decodeFromString, $author$project$Acadia$Api$createOrganizationCodec, request.body);
								if (_v9.$ === 'Nothing') {
									return $author$project$Server$acadiaFailureResponse(
										{
											error: $author$project$Http$Extended$Generic('Server error'),
											status: $author$project$Http$Status$BadRequest
										});
								} else {
									var newOrg = _v9.a;
									return ($elm$core$String$length(newOrg.name) < 1) ? $author$project$Server$acadiaFailureResponse(
										{
											error: $author$project$Http$Extended$Field(
												{message: 'Too short', name: 'name'}),
											status: $author$project$Http$Status$BadRequest
										}) : A3(
										$author$project$Server$acadiaRequest,
										request.headers,
										$author$project$Server$OrganizationCreateResponse($author$project$Acadia$Api$organizationCodec),
										$author$project$Backend$createOrganization(newOrg));
								}
						}
					}
				}
			}
		}());
};
var $elm$core$Platform$Sub$batch = _Platform_batch;
var $elm$core$Platform$Sub$none = $elm$core$Platform$Sub$batch(_List_Nil);
var $author$project$Server$subscriptions = function (_v0) {
	return $elm$core$Platform$Sub$none;
};
var $author$project$Http$Status$StatusOk = {$: 'StatusOk'};
var $author$project$Server$setPathOnCookie = function (cookie) {
	return cookie + '; Path=/api';
};
var $author$project$Server$acadiaResponse = F2(
	function (codec, result) {
		if (result.$ === 'Err') {
			return $author$project$Server$respond(
				{body: 'Database error', headers: _List_Nil, status: $author$project$Http$Status$BadRequest});
		} else {
			var _v1 = result.a;
			var headers = _v1.a;
			var body = _v1.b;
			return $author$project$Server$respond(
				{
					body: A2($author$project$Serialize$encodeToString, codec, body),
					headers: A2(
						$elm$core$List$filterMap,
						function (_v2) {
							var key = _v2.a;
							var value = _v2.b;
							var _v3 = $elm$core$String$toLower(key);
							switch (_v3) {
								case 'content-length':
									return $elm$core$Maybe$Nothing;
								case 'set-cookie':
									return $elm$core$Maybe$Just(
										_Utils_Tuple2(
											key,
											$author$project$Server$setPathOnCookie(value)));
								default:
									return $elm$core$Maybe$Just(
										_Utils_Tuple2(key, value));
							}
						},
						headers),
					status: $author$project$Http$Status$StatusOk
				});
		}
	});
var $author$project$Server$update = F2(
	function (msg, model) {
		switch (msg.$) {
			case 'LoginResponse':
				var codec = msg.a;
				var result = msg.b;
				return _Utils_Tuple2(
					model,
					A2($author$project$Server$acadiaResponse, codec, result));
			case 'AuthLogoutResponse':
				var codec = msg.a;
				var result = msg.b;
				return _Utils_Tuple2(
					model,
					A2($author$project$Server$acadiaResponse, codec, result));
			case 'AuthSelfResponse':
				var codec = msg.a;
				var result = msg.b;
				return _Utils_Tuple2(
					model,
					A2($author$project$Server$acadiaResponse, codec, result));
			default:
				var codec = msg.a;
				var result = msg.b;
				return _Utils_Tuple2(
					model,
					A2($author$project$Server$acadiaResponse, codec, result));
		}
	});
var $elm$json$Json$Decode$value = _Json_decodeValue;
var $elm$core$Platform$worker = _Platform_worker;
var $author$project$Server$main = $elm$core$Platform$worker(
	{init: $author$project$Server$init, subscriptions: $author$project$Server$subscriptions, update: $author$project$Server$update});
/*
_Platform_export({'Server':{'init':$author$project$Server$main($elm$json$Json$Decode$value)(0)}});}(this));
*/
export const Elm = {'Server':{'init':$author$project$Server$main($elm$json$Json$Decode$value)(0)}};
  