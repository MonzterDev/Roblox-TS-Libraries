return {
	-- Symbols
	groupingSymbol = ",",
	decimalSymbol = ".",
	infinitySymbol = "∞",
	-- If you want to change the NaN symbol and you don't have any knowledge about NaN payloads, use this one.
	quietNaNSymbol = "NaNQ",
	-- In this context, if the 52th least significant bit is on then it's quiet NaN
	-- otherwise it's signaling NaN though this actually depends on the CPU.
	-- You'll almost certainly never encounter signaling NaN in Roblox unless it was intentional.
	-- But you can encounter this by converting "nan(snan)" to number.
	signalingNaNSymbol = "NaNS",

	-- Suffixes displayed for every power of thousands
	-- The default is K, M, B, T - similar to the one provided by Unicode CLDR.
	-- You can add more or change the suffixes provided here.
	compactSuffix = {
		"K", "M", "B", "T",
	},

	-- advanced configurations --
	showNaNPayload = true,

	-- Will only work if the FTZ flag is on and the DAZ flag is off
	-- If the DAZ flag is on then this option will always be true even if you set it to 'false'
	-- If the FTZ flag is off (and the DAZ flag is off) then this option will always be false even if you set it to 'true'.
	-- Currently the Roblox engine has the FTZ flag on but not the DAZ flag
	subnormalsAsZero = false,
}