--!strict
local config = require(script.Parent.config)
local _aux = { }

local GROUPING_SYMBOL = config.groupingSymbol
local DECIMAL_SYMBOL = config.decimalSymbol
local INFINITY_SYMBOL = config.infinitySymbol
local QUIET_NAN_SYMBOL = config.quietNaNSymbol
local SIGNALING_NAN_SYMBOL = config.signalingNaNSymbol
local SHOW_NAN_PAYLOAD = config.showNaNPayload
local SUBNORMALS_AS_ZERO = config.subnormalsAsZero

function _aux.round_sig(fmt: { number }, fmt_n: number, sig: number): (number, boolean)
	local incr_e = false

	if sig <= 0 then
		fmt_n = 0
	elseif fmt_n > sig then
		local incr = fmt[sig + 1] > 5 or
			fmt[sig + 1] == 5 and (fmt_n > sig + 1
				or fmt[sig] % 2 == 1)

		fmt_n = sig

		if incr then
			while fmt[fmt_n] == 9 and fmt_n > 0 do
				fmt_n -= 1
			end

			if fmt_n == 0 then
				fmt[1] = 1
				fmt_n = 1
				incr_e = true
			else
				fmt[fmt_n] += 1
			end
		end
	end

	return fmt_n, incr_e
end

local function internal_get_digits(fmt: { number }, fmt_n: number, i: number, j: number): string
	local leftz, strd, rightz, rightzn

	if i <= 0 then
		leftz = string.rep("0", -i + 1)
		i = 1
	else
		leftz = ""
	end

	rightzn = j - math.max(fmt_n, i - 1)
	if rightzn <= 0 then
		rightz = ""
	else
		j = fmt_n
		rightz = string.rep("0", rightzn)
	end

	if i > fmt_n then
		strd = ""
	else
		strd = string.char(table.unpack(fmt, i, j))
	end

	return leftz .. strd .. rightz
end

function _aux.format_unsigned_finite(
	fmt: { number }, fmt_n: number, marker: number,
	req_digits: number?, min_grouping: number?): string
	local intg, frac

	for i = 1, fmt_n do
		fmt[i] += 0x30
	end

	intg = internal_get_digits(fmt, fmt_n, 1, marker)
	frac = internal_get_digits(fmt, fmt_n, marker + 1, req_digits or fmt_n)

	if intg == "" then
		intg = "0"
	elseif min_grouping and marker >= min_grouping then
		intg = string.reverse((string.gsub(string.reverse(intg),
			"...", "%0" .. GROUPING_SYMBOL, (marker - 1) / 3
		)))
	end

	if frac == "" then
		return intg
	end

	return intg .. DECIMAL_SYMBOL .. frac
end

function _aux.format_special(value: number, req_digits: number, req_e: boolean): string?
	-- Check for infinite, NaN, and zero values
	local result = nil

	if value ~= value then
		-- NaN
		local sigt0, sigt1, sigt2, sigt3, sigt4, sigt5, sigt6, sign =
			string.byte(string.pack("<d", value), 1, 8)
		if bit32.band(sigt6, 0x08) == 0 then
			result = SIGNALING_NAN_SYMBOL
		else
			result = QUIET_NAN_SYMBOL
		end
		if sign > 0x7F then
			result = "-" .. result
		end

		if SHOW_NAN_PAYLOAD then
			result ..= string.format(
				" 0x%01X%02X%02X%02X%02X%02X%02X",
				bit32.band(sigt6, 0x0F),
				sigt5, sigt4, sigt3, sigt2, sigt1, sigt0
			)
		end
	elseif value == math.huge then
		-- +Infinity
		result = INFINITY_SYMBOL
	elseif value == -math.huge then
		-- -Infinity
		result = "-" .. INFINITY_SYMBOL
	elseif value == 0 or SUBNORMALS_AS_ZERO and value * 1 == 0 then
		-- +0 and -0
		result = if math.atan2(value, -1) < 0 then "-0" else "0"
		if req_digits > 1 then
			result ..= DECIMAL_SYMBOL
				.. string.rep("0", req_digits - 1)
		end
		if req_e then
			result ..= "E0"
		end
	end

	return result
end

return table.freeze(_aux)