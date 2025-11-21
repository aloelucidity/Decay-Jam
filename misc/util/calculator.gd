class_name CalculatorUtil


const METER_WIDTH: float = 32
const DISTANCE_MULTIPLIER: float = 0.05
const ASCENT_MULTIPLIER: float = 0.1


static func to_meters(pixels: float) -> float:
	return pixels / METER_WIDTH


static func to_kilometers_per_hour(pixels_per_second: float) -> float:
	var meters_per_second: float = abs(pixels_per_second) / METER_WIDTH
	var kilometers_per_hour: float = (meters_per_second * 60 * 60) / 1000
	return kilometers_per_hour


static func fragments_to_money(fragments: int) -> int:
	return fragments


static func robots_to_money(robots: int) -> int:
	return robots * 10


static func distance_to_multiplier(distance_pixels: float) -> float:
	return 1 + (distance_pixels * DISTANCE_MULTIPLIER / 1000)


static func ascent_to_multiplier(ascent_pixels: float) -> float:
	return 1 + (ascent_pixels * ASCENT_MULTIPLIER / 1000)


static func calculate_money_total(fragments: int, robots: int) -> int:
	@warning_ignore("narrowing_conversion")
	return fragments_to_money(fragments) + robots_to_money(robots)


static func calculate_multiplier_total(distance_pixels: float, ascent_pixels: float) -> float:
	return 1 + (
		distance_to_multiplier(distance_pixels) - 1
		+ ascent_to_multiplier(ascent_pixels) - 1
	)


static func mix_money_total(fragments_money: int, robots_money: int) -> int:
	return fragments_money + robots_money


static func mix_multiplier_total(distance_mult: float, ascent_mult: float) -> float:
	return 1 + distance_mult - 1 + ascent_mult - 1
