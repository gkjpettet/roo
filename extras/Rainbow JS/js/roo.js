/**
 * Roo language patterns
 *
 * @author Dr Garry Pettet
 */
Rainbow.extend('roo', [
    {
        name: 'operator',
        pattern: /&(gt|lt|amp);|[+-/*%&=<>|!^:?]/g
    },

    // Numbers
    {
        name: 'number',
        pattern: /\b[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?\b/g
    },
    {
        name: 'number.hex',
        pattern: /(0x[A-Fa-f0-9]+)\b/g
    },
    {
        name: 'number.binary',
        pattern: /(0b[0-1]+)\b/g
    },    
    {
        name: 'number.octal',
        pattern: /(0o[0-7]+)\b/g
    },

    {
        name: 'keyword',
        pattern: /\b(False|True|and|break|class|def|else|exit|for|if|module|not|or|pass|quit|require|return|self|static|super|var|while)\b/g
    },
    {
        name: 'string',
        pattern: /"(?:.|\s)*?[^\\]"|'(?:.|\s)*?[^\\]'/gm
    },

    {
        name: 'comment',
        pattern: /(\#).*?$/gm
    },    

    // Invokable entities (followed by brackets)
    {
        name: 'invokable.ucase',
        pattern: /[A-Z][A-Za-z_0-9]*[!?]?(?=\()/g
    },
    {
        name: 'invokable.lcase',
        pattern: /[a-z_][A-Za-z_0-9]*[!?]?(?=\()/g
    },

    // Identifiers
    {
        name: 'identifier.ucase',
        pattern: /[A-Z][A-Za-z_0-9]*/g
    },
    {
        name: 'identifier.lcase',
        pattern: /[a-z_][A-Za-z_0-9]*/g
    },

    {
        matches: {
            1: 'operator',
            2: 'getter'
        },
        pattern: /(\.)([A-Za-z_]+\b(?!\()(?!\?\()(?!\!\())/g
    }
]); 