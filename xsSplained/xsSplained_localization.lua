-- xsSplained_localization.lua
local mod = get_mod("xsSplained")

local localization = {
    mod_name = {
        en = "Game Mechanics Explained",
        ["zh-cn"] = "游戏机制说明",
        ru = "Объяснение игровых механик",
    },
    mod_description = {
        en = "Adds a page with detailed explanations of game mechanics",
        ["zh-cn"] = "添加包含游戏机制详细说明的页面",
        ru = "Добавляет страницу с подробным объяснением игровых механик",
    },
    mechanics_tab_name = {
        en = "Mechanics",
        ["zh-cn"] = "游戏机制",
        ru = "Механики",
    },
    strength_title = {
        en = "Strength",
        ["zh-cn"] = "力量",
        ru = "Сила",
    },
    strength_description = {
        en = "Strength - increases damage, armor penetration and stagger.\n\n[img:"..strength_img.."]",
        ["zh-cn"] = "力量 - 增加伤害、护甲穿透和击晕效果。\n\n[img:"..strength_img.."]",
        ru = "Сила - увеличивает урон, пробивание брони и ошеломление.\n\n[img:"..strength_img.."]",
    },
    agility_title = {
        en = "Agility",
        ["zh-cn"] = "敏捷",
        ru = "Ловкость",
    },
    agility_description = {
        en = "Agility - increases attack speed, dodge distance and movement speed.\n\n[img:"..agility_img.."]",
        ["zh-cn"] = "敏捷 - 增加攻击速度、闪避距离和移动速度。\n\n[img:"..agility_img.."]",
        ru = "Ловкость - увеличивает скорость атаки, расстояние уклонения и скорость передвижения.\n\n[img:"..agility_img.."]",
    },
    toughness_title = {
        en = "Toughness",
        ["zh-cn"] = "坚韧",
        ru = "Выносливость",
    },
    toughness_description = {
        en = "Toughness - reduces incoming damage and increases resistance to stagger.\n\n[img:"..toughness_img.."]",
        ["zh-cn"] = "坚韧 - 减少受到的伤害并增加对击晕的抗性。\n\n[img:"..toughness_img.."]",
        ru = "Выносливость - уменьшает получаемый урон и увеличивает сопротивление ошеломлению.\n\n[img:"..toughness_img.."]",
    },
    armor_penetration_title = {
        en = "Armor Penetration",
        ["zh-cn"] = "护甲穿透",
        ru = "Пробивание брони",
    },
    armor_penetration_description = {
        en = "Armor Penetration - increases effectiveness against armored enemies.\n\n[img:"..armor_img.."]",
        ["zh-cn"] = "护甲穿透 - 提高对装甲敌人的效果。\n\n[img:"..armor_img.."]",
        ru = "Пробивание брони - увеличивает эффективность против бронированных врагов.\n\n[img:"..armor_img.."]",
    },
}

return localization