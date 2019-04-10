// ARFF parser
//
// Sparse ARFF files are not supported!
//
// Source: http://www.cs.waikato.ac.nz/ml/weka/arff.html

{
	var forEach = require('lodash.foreach');
	var moment = require('moment');

	var attributes = [];
	function registerAttribute(name, type) {
		if (typeof type === 'string') {
			type = {
				type: type,
			}
		}

		type.name = name;

		attributes.push(type);
	}

	function makeDatum(fields) {
		var datum = {};
		forEach(fields, function (value, index) {
			if (value === undefined) {
				return;
			}

			var attr = attributes[index];
			if (!attr) {
				return;
			}

			var type = attr.type;
			if (type === 'date') {
				var date = moment.utc(value, attr.format);
				if (date.isValid()) {
					value = date.toDate();
				}
				else {
					return;
				}
			} else if (type === 'numeric') {
				value = +value;
			} else if (type === 'enum') {
				if (attr.values.indexOf(value) === -1) {
					throw new Error(
						value +' is not valid for the '+ attr.name + ' attribute'
					);
				}
			}

			datum[attr.name] = value;
		});

		return datum;
	}
}

start =
	(ws* nl)*
	description:description?
	relation:relation?
	separator
	attribute
	(
		separator
		attribute
	)*
	separator
	data:data
	separator? {
		return {
			relation: relation,
			description: description,
			attributes: attributes,
			data: data
		};
	}

//====================================================================
// Comment

separator = (nl / comment nl / ws+ nl)+

comment = '%' (!nl .)*

commentline = '%' ws? string:(string / ws)* nl+{
	return string.join("");
}

description = description:(commentline)*{
	return description.join("\n");
}

//====================================================================
// Relation

relation = '@relation'i ws+ name:string {
	return name;
}

//====================================================================
// Attribute

attribute = '@attribute'i ws+ name:string ws+ type:type {
	registerAttribute(name, type);
}

type
	= date
	/ class
	/ 'numeric'i {
		return 'numeric';
	}
	/ 'integer'i {
		return 'numeric';
	}
	/ 'real'i {
		return 'numeric';
	}
	/ 'string'i {
		return 'string';
	}

date 'date'
	= 'date'i ws+ format:string {
		return {
			type: 'date',
			format: format
		};
	}
	/ 'date'i {
		return 'date';
	}

class 'class' = '{' first:string rest:(virgule value:string { return value; })* '}' {
	rest.unshift(first);
	return {
		type: 'enum',
		values: rest
	};
}

//====================================================================
// Data

data = '@data'i values:(separator datum:datum { return datum; })* {
	return values;
}

datum = first:value rest:(virgule value:value { return value; })* {
	rest.unshift(first);
	return makeDatum(rest);
}

value
	=  '?' {
		// undefined
	}
	/ string

//====================================================================
// String
// See https://github.com/pegjs/pegjs/blob/fba70833dd93d61cc1574b855a67ff6af71dfe40/examples/json.pegjs#L101

string 'string' = chars:(rawString / singleQuotedString / doubleQuotedString) {
	return chars.join('');
}

rawString = [^ \r\n\t'",{}]i+

singleQuotedString = "'" chars:([^'\\] / escapedChar)* "'" {
	return chars;
}

doubleQuotedString = '"' chars:([^"\\] / escapedChar)* '"' {
	return chars;
}

escapedChar 'escaped char' = '\\' sequence:(
		"'"
	/ '"'
	/ '\\'
	/ '/'
	/ 'b' { return '\b'; }
	/ 'f' { return '\f'; }
	/ 'n' { return '\n'; }
	/ 'r' { return '\r'; }
	/ 't' { return '\t'; }
	/ 'u' digits:$(HEXDIG HEXDIG HEXDIG HEXDIG) {
		return String.fromCharCode(parseInt(digits, 16));
	}
) {
	return sequence;
}

HEXDIG = [0-9a-f]i

//====================================================================
// Common

nl 'new line' = '\r\n' / '\n' / '\r'

ws 'whitespace' = [ \t]

virgule 'virgule' = _ ',' _

// optional whitespace
_  = [ \t\r\n]*
