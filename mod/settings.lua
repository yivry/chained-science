require("prefix")

data:extend({{
    type = "bool-setting",
    name = pf("blue-before-gray"),
    setting_type = "startup",
    default_value = false,
}})

data:extend({{
    type = "bool-setting",
    name = pf("ignore-gray"),
    setting_type = "startup",
    default_value = false,
}})

data:extend({{
    type = "bool-setting",
    name = pf("yellow-before-purple"),
    setting_type = "startup",
    default_value = false,
}})
