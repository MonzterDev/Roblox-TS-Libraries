# Format-Number-TS

This contains the typing for [Blockzez's FormatNumber Lib](https://devforum.roblox.com/t/310-formatnumber-a-module-for-formatting-numbers/527979/42)

## Usage

There are a few functions included:

```TS
/**
    * Formats an integer.
    *
    * The argument internally is casted to 64 bit integer in the same way as string.format %d is.
*/
export declare const FormatInt: ( value: number ) => string

/**
    * Formats a number.
*/
export declare const FormatStandard: ( value: number ) => string

/**
    * Formats a number rounded to the certain decimal places.
    *
    * The default is 6 decimal places.
    *
    * Bankers' rounding is used.
*/
export declare const FormatFixed: ( value: number, digits?: number ) => string

/**
    * Formats a number rounded to the certain significant digits.
    *
    * The default is 6 significant digits.
    *
    * Bankers' rounding is used.
*/
export declare const FormatPrecision: ( value: number, digits?: number ) => string

/**
    * Formats a number so it is in compact form (abbreviated such as "1000" to "1K").
    *
    * The significand (referring to 1.2 in "1.2K") is truncated to certain decimal places specified in the fractionDigits argument. If the fractionDigits argument is not provided, then the significand is truncated to integers but keeping 2 significant digits.
    *
    * You can change the suffix by changing the `compactSuffix` field from the `config` ModuleScript included in the module.
*/
export declare const FormatCompact: ( value: number, fractionDigits?: number ) => string

/**
    * Undocumented
    *
    * If you don't know what this does, you probably don't need this.
*/
export declare const FormatAsBinaryIEEE: ( value: number ) => string
```