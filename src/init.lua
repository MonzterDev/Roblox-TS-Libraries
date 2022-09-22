--[[
Licence:
FormatNumber
Version 3.0.0b3 (Alternative API)
BSD 2-Clause Licence
Copyright 2022 - Blockzez (https://devforum.roblox.com/u/Blockzez and https://github.com/Blockzez)
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]


local config = require(script.config)
local _aux = require(script._aux)
local FormatNumber = { }

local GROUPING_SYMBOL = config.groupingSymbol
local COMPACT_SUFFIX = config.compactSuffix

--- API
--[[
All of these function formats so the integer part of the formatted number are separted by the grouping separator (commas by default) every 3 digits.
]]


--[[
Formats an integer.
The argument internally is casted to 64 bit integer in the same way as string.format %d is.
]]
function FormatNumber.FormatInt(value: number): string
	local fmt, result

	assert(type(value) == "number", "Value provided must be a number")

	-- %d casts IEEE doubles to signed 64-bit integers in Roblox
	fmt = string.format("%+d", value)

	result = string.sub(fmt, if string.byte(fmt) == 0x2D then 1 else 2, 2)
	result ..= string.reverse(
		(string.gsub(
			string.reverse(string.sub(fmt, 3)),
			"...", "%0" .. GROUPING_SYMBOL
		))
	)

	return result
end

-- Anything beyond this point requires the DoubleConversion module
local DoubleConversion = script.DoubleConversion
local DoubleToDecimalConverter = require(DoubleConversion.DoubleToDecimalConverter)

--[[
Formats a number.
]]
function FormatNumber.FormatStandard(value: number): string
	local result

	assert(type(value) == "number", "Value provided must be a number")

	result = _aux.format_special(value, 0, false)

	if not result then
		local fmt, fmt_n, scale
		local marker

		fmt, fmt_n, scale = DoubleToDecimalConverter.ToShortest(value)
		marker = scale + fmt_n

		result = _aux.format_unsigned_finite(fmt, fmt_n, marker, nil, 4)

		if value < 0 then
			result = "-" .. result
		end
	end

	return result
end


--[[
Formats a number rounded to the certain decimal places.
The default is 6 decimal places.
Bankers' rounding is used.
]]
function FormatNumber.FormatFixed(value: number, digits: number?): string
	local result

	assert(type(value) == "number", "Value provided must be a number")

	if digits == nil then
		digits = 6
	end
	assert(
		type(digits) == "number" and math.floor(digits) == digits,
		"Digits provided must be an integer"
	)
	assert(digits >= 0 and digits <= 9999, "Digits out of the range (0..9999)")

	result = _aux.format_special(value, digits + 1, false)

	if not result then
		local fmt, fmt_n, scale
		local marker
		local sigd
		local incr_e

		fmt, fmt_n, scale = DoubleToDecimalConverter.ToExact(value)
		marker = scale + fmt_n
		sigd = marker + digits
		fmt_n, incr_e = _aux.round_sig(fmt, fmt_n, sigd)

		if incr_e then
			marker += 1
			sigd += 1
		elseif fmt_n == 0 then
			-- edge case for values rounded to zero
			marker = 1
			sigd = digits
		end

		result = _aux.format_unsigned_finite(fmt, fmt_n, marker, sigd, 4)

		if value < 0 then
			result = "-" .. result
		end
	end

	return result
end

--[[
Formats a number rounded to the certain significant digits.
The default is 6 significant digits.
Bankers' rounding is used.
]]
function FormatNumber.FormatPrecision(value: number, digits: number?): string
	local result

	assert(type(value) == "number", "Value provided must be a number")

	if digits == nil then
		digits = 6
	end
	assert(
		type(digits) == "number" and math.floor(digits) == digits,
		"Digits provided must be an integer"
	)
	assert(digits >= 1 and digits <= 9999, "Digits out of the range (1..9999)")

	result = _aux.format_special(value, digits, false)

	if not result then
		local fmt, fmt_n, scale
		local marker
		local incr_e

		fmt, fmt_n, scale = DoubleToDecimalConverter.ToExact(value)
		marker = scale + fmt_n
		fmt_n, incr_e = _aux.round_sig(fmt, fmt_n, digits)

		if incr_e then
			marker += 1
		end

		result = _aux.format_unsigned_finite(fmt, fmt_n, marker, digits, 4)

		if value < 0 then
			result = "-" .. result
		end
	end

	return result
end

--[[
Formats a number so it is in compact form (abbreviated such as "1000" to "1K").
The significand (referring to 1.2 in "1.2K") is truncated to certain decimal places specified in the fractionDigits argument. If the fractionDigits argument is not provided, then the significand is truncated to integers but keeping 2 significant digits.
You can change the suffix by changing the `compactSuffix` field from the `config` ModuleScript included in the module.
]]
function FormatNumber.FormatCompact(value: number, fractionDigits: number?): string
	local result

	assert(type(value) == "number", "Value provided must be a number")

	if fractionDigits ~= nil then
		assert(
			type(fractionDigits) == "number"
				and math.floor(fractionDigits) == fractionDigits,
			"Digits provided must be an integer"
		)
		assert(fractionDigits >= 0 and fractionDigits <= 999,
			"Digits out of the range (0..999)")
	end

	result = _aux.format_special(value, 0, false)

	if not result then
		local fmt, fmt_n, scale
		local marker
		local selected_postfix = nil
		local selected_i

		fmt, fmt_n, scale = DoubleToDecimalConverter.ToShortest(value)
		marker = scale + fmt_n

		selected_i = math.min(math.floor((marker - 1) / 3),
			#COMPACT_SUFFIX)
		if selected_i > 0 then
			marker -= selected_i * 3
			selected_postfix = COMPACT_SUFFIX[selected_i]
		end

		-- try to truncate
		if fractionDigits then
			fmt_n = math.min(fmt_n, marker + fractionDigits)

			if fmt_n <= 0 then
				marker = 1
				fmt_n = 0
			end
		elseif fmt_n > 2 then
			fmt_n = math.clamp(fmt_n, 2, marker)
		end

		result = _aux.format_unsigned_finite(fmt, fmt_n, marker, nil, 5)

		if value < 0 then
			result = "-" .. result
		end

		if selected_postfix then
			result ..= selected_postfix
		end
	end

	return result
end
--

-- Undocumented
-- If you don't know what this does, you probably don't need this.
function FormatNumber.FormatAsBinaryIEEE(value: number): string
	local bin_chr = table.create(66)
	local i0 = 1
	for i1, byte in ipairs{ string.byte(string.pack(">d", value), 1, 8) } do
		local i2 = 0x80
		for _ = 1, 8 do
			bin_chr[i0] = if bit32.band(byte, i2) == 0
				then 0x30 else 0x31
			i2 /= 2

			if i1 == 1 and i2 == 0x40 or i1 == 2 and i2 == 0x08 then
				bin_chr[i0 + 1] = 0x20
				i0 += 2
			else
				i0 += 1
			end
		end
	end

	return string.char(table.unpack(bin_chr, 1, 66))
end

return table.freeze(FormatNumber)