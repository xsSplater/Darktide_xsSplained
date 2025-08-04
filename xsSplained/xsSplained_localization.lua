-- xsSplained_localization.lua
local mod = get_mod("xsSplained")

local localization = {
	mod_name = {
		en = "xsSplained",
		ru = "СанСаныч пояснит",
	},
	mod_description = {
		en = "Adds a page with Game Mechanics xsSplanations.",
		ru = "xsSplained - Добавляет страницу с объяснением игровых механик.",
	},
	mechanics_tab_name = {
		en = "Mechanics xsSplanations",
		ru = "Пояснение механик",
	},
	strength_title = {
		en = "Strength",
		ru = "Сила - Strength",
	},
	strength_description = {
		en = "Strength - increases damage, armor penetration and stagger.",
		ru = "Сила - увеличивает ваш урон, пробивание вами брони врагов и ошеломление, которое враги получают от вас.",
	},
	finesse_title = {
		en = "Finesse",
		ru = "Ловкость - Finesse",
	},
	finesse_description = {
		en = "Finesse - increases attack speed, dodge distance and movement speed.",
		ru = "Ловкость - увеличивает скорость атаки, расстояние уклонения и скорость передвижения.",
	},
	toughness_title = {
		en = "Toughness",
		ru = "Стойкость - Toughness",
	},
	toughness_description = {
		en = "Toughness - reduces incoming damage and increases resistance to stagger.",
		ru = "Стойкость - уменьшает получаемый урон и увеличивает сопротивление ошеломлению.",
	},
	rending_title = {
		en = "Rending",
		ru = "Пробивание брони - Rending",
	},
	rending_description = {
		en = "Rending - increases effectiveness against armored enemies.",
		ru = "Пробивание брони - увеличивает эффективность против бронированных врагов.",
	},
	-- cleave_title = {
		-- en = "Cleave",
		-- ru = "",
	-- },
	-- cleave_description = {
		-- en = "The Cleave System\n Cleave is a measure of how many enemies your attack can pass through before losing its effectiveness. It’s influenced by weapon stats, attack type, and enemy hit mass. Here’s how it works:\n\n The Basics\n Weapons have cleave values: Each attack type has a cleave value that determines how many enemies it can pass through. For instance, a Power Sword charged attack might have 11.7 cleave.\n Enemies have hit mass: Each enemy consumes a portion of cleave. For example, if an enemy’s hit mass is 1.5, the Power Sword can hit up to 8 enemies in one swing (7 × 1.5 = 10.5, leaving 1.2 cleave for the 8th target).\n When cleave is exhausted, the attack stops.\n Cleave Damage Distribution\n Melee attacks distribute damage based on cleave mechanics. For example:\n Strikedown attacks (e.g., heavy overheads): Damage is focused on the first target (100%), with reduced damage for subsequent targets (e.g., 25% for the second target).\n Vanguard attacks (e.g., wide sweeps): Damage is distributed more evenly (e.g., 100% for the first target, 75% for the second, 50% for the third, etc.).\n Example: Eviscerators\n Eviscerators’ light attacks can hit up to 4 targets, with the rest being staggered. This is due to their cleave damage cap, making them great for crowd control but less effective for pure damage output.\n\n Cleave and Blessings\n Brutal Momentum: Ignores cleave damage reduction for 3 targets after a weak spot kill, ensuring maximum damage output to additional enemies.\n Carapace Armor Interactions: Cleave is halted entirely by carapace armor unless using specific blessings like Sunder or Perfect Strike.",
		-- ru = "",
	-- },
}

return localization