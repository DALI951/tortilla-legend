extends Node

signal language_changed(lang: String)

var current_language: String = "en"
var translations: Dictionary = {}

const SUPPORTED_LANGUAGES: Array[String] = ["en", "ar"]

const DEFAULT_TRANSLATIONS: Dictionary = {
	"en": {
		"game_title": "Tortilla Legend",
		"play": "PLAY",
		"kitchen": "KITCHEN",
		"day_label": "Day %d",
		"pause": "PAUSE",
		"resume": "RESUME",
		"serve": "SERVE",
		"money": "Money",
		"customers_served": "Customers Served",
		"customers_lost": "Customers Lost",
		"wrong_orders": "Wrong Orders",
		"thief_losses": "Thief Losses",
		"continue": "CONTINUE",
		"back": "BACK",
		"settings": "SETTINGS",
		"language": "Language",
		"sfx_volume": "SFX Volume",
		"upgrade_toggles": "UPGRADE TOGGLES",
		"customer_choice": "Customer Ingredient Choice",
		"customer_choice_desc": "Customers can request ingredient removals",
		"day_complete": "DAY %d COMPLETE",
		"money_earned": "Money Earned",
		"classic_order": "Classic",
		"no_ingredient": "No %s",
		"upgrade_purchased": "Upgrade Purchased!",
		"congratulations": "Congratulations!",
		"you_are_the_legend": "You Are The Tortilla Legend!",
		"endless_unlocked": "Endless Mode Unlocked!",
		"play_endless": "PLAY ENDLESS",
		"total_money_earned": "Total Money Earned",
		"total_customers_served": "Total Customers Served",
		"thief_coming": "Thief!",
	},
	"ar": {
		"game_title": "\u0633\u064a\u0646\u0629 \u0627\u0644\u062a\u0648\u0631\u062a\u064a\u0644\u064a\u0627",
		"play": "\u0627\u0644\u0644\u0639\u0628",
		"kitchen": "\u0627\u0644\u0645\u0637\u0628\u062e",
		"day_label": "\u0627\u0644\u064a\u0648\u0645 %d",
		"pause": "\u0625\u064a\u0642\u0627\u0641",
		"resume": "\u0627\u0633\u062a\u0626\u0646\u0627\u0641",
		"serve": "\u062a\u0642\u062f\u064a\u0645",
		"money": "\u0627\u0644\u0641\u0644\u0648\u0633",
		"customers_served": "\u0627\u0644\u0632\u0628\u0627\u0621 \u0627\u0644\u0645\u062e\u062f\u0645\u064a\u0646",
		"customers_lost": "\u0627\u0644\u0632\u0628\u0627\u0621 \u0627\u0644\u0645\u0641\u0642\u062f\u064a\u0646",
		"wrong_orders": "\u0637\u0644\u0628\u0627\u062a \u062e\u0627\u0637\u0626\u0629",
		"thief_losses": "\u062e\u0633\u0627\u0626\u0631 \u0627\u0644\u0644\u0633\u062a\u0627\u0631\u0642",
		"continue": "\u0627\u0633\u062a\u0645\u0631\u0627\u0639",
		"back": "\u0631\u062c\u0648\u0639",
		"settings": "\u0627\u0644\u0625\u0639\u062f\u0627\u062f\u0627\u062a",
		"language": "\u0627\u0644\u0644\u063a\u0629",
		"sfx_volume": "\u0627\u0644\u0635\u0648\u062a",
		"upgrade_toggles": "\u062a\u0639\u0637\u064a\u0644 \u0627\u0644\u062a\u062d\u0633\u064a\u0646\u0627\u062a",
		"customer_choice": "\u062e\u064a\u0627\u0631\u0629 \u0627\u0644\u0645\u0643\u0648\u0646\u0627\u062a",
		"customer_choice_desc": "\u0627\u0644\u0632\u0628\u0627\u0621 \u064a\u0645\u0643\u0646\u0647\u0645 \u0637\u0644\u0628 \u0625\u0632\u0627\u0644\u0629 \u0645\u0643\u0648\u0646\u0627\u062a",
		"day_complete": "\u0627\u0646\u062a\u0647\u0649 \u0627\u0644\u064a\u0648\u0645 %d",
		"money_earned": "\u0627\u0644\u0645\u063a\u0632\u064b\u0627 \u0627\u0644\u0645\u062d\u0635\u0648\u0644",
		"classic_order": "\u0643\u0644\u0627\u0633\u064a\u0643",
		"no_ingredient": "\u0628\u062f\u0648\u0646 %s",
		"upgrade_purchased": "\u062a\u0645 \u0634\u0631\u0627\u0621 \u0627\u0644\u062a\u062d\u0633\u064a\u0646!",
		"congratulations": "\u0645\u0628\u0631\u0648\u0643!",
		"you_are_the_legend": "\u0623\u0646\u062a \u0623\u0633\u0637\u0631 \u062a\u0648\u0631\u062a\u064a\u0644\u064a\u0627!",
		"endless_unlocked": "\u062a\u0645 \u0641\u062a\u062d \u0627\u0644\u0648\u0636\u0639 \u0627\u0644\u0644\u0627 \u0646\u0647\u0627\u0626\u064a\u0629!",
		"play_endless": "\u0644\u0639\u0628 \u0627\u0644\u0648\u0636\u0639 \u0627\u0644\u0644\u0627 \u0646\u0647\u0627\u0626\u064a",
		"total_money_earned": "\u0625\u062c\u0645\u0627\u0644\u064a \u0627\u0644\u0645\u063a\u0632\u064b\u0627 \u0627\u0644\u0645\u062d\u0635\u0648\u0644\u0629",
		"total_customers_served": "\u0625\u062c\u0645\u0627\u0644\u064a \u0627\u0644\u0632\u0628\u0627\u0621 \u0627\u0644\u0645\u062e\u062f\u0645\u064a\u0646",
		"thief_coming": "\u0627\u0644\u0644\u0633\u062a\u0627\u0631\u0642!",
	}
}

func _ready() -> void:
	load_translations()

func load_translations() -> void:
	translations = DEFAULT_TRANSLATIONS.duplicate(true)

func set_language(lang: String) -> void:
	if lang in SUPPORTED_LANGUAGES:
		current_language = lang
		language_changed.emit(lang)

func tr(key: String) -> String:
	if translations.has(current_language) and translations[current_language].has(key):
		return translations[current_language][key]
	if translations.has("en") and translations["en"].has(key):
		return translations["en"][key]
	return key

func is_rtl() -> bool:
	return current_language == "ar"
