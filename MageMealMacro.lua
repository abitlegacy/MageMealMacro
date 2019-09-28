local MageMealMacro = CreateFrame("Button", "MageMealMacro", UIParent, "SecureActionButtonTemplate")
MageMealMacro:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
MageMealMacro:SetAttribute("type", "macro");
MageMealMacro:SetAttribute("macrotext", "/run MageMealMacro:Update()");
local Drinks = {
	"Conjured Crystal Water",
	"Conjured Sparkling Water",
	"Conjured Mineral Water",
	"Conjured Spring Water",
	"Conjured Purified Water",
	"Conjured Fresh Water",
	"Conjured Water"
}
local Foods = {
	"Conjured Cinnamon Roll",
	"Conjured Sweet Roll",
	"Conjured Sourdough",
	"Conjured Pumpernickel",
	"Conjured Rye",
	"Conjured Bread",
	"Conjured Muffin"
}
local AURAS = {Drink = true, Food = true}

local ICONS = {
  -- Drink
  [8079] = true,
  [8078] = true,
  [8077] = true,
  [3772] = true,
  [2136] = true,
  [5350] = true,
  [2288] = true,
  -- Food
  [22895] = true,
  [8076] = true,
  [8075] = true,
  [1487] = true,
  [1114] = true,
  [1113] = true,
  [587] = true
}

local health_threshold = .9
local mana_threshold = 1


MageMealMacro:RegisterEvent("PLAYER_ENTERING_WORLD")
function MageMealMacro:PLAYER_ENTERING_WORLD()
  -- Refresh macro icon
  if not IsAddOnLoaded("Blizzard_MacroUI") then
    LoadAddOn("Blizzard_MacroUI")
  end
  hooksecurefunc("MacroFrame_SaveMacro", function() MageMealMacro:BAG_UPDATE() end)
	if GetMacroIndexByName("MageMealMacro") == 0 then
		-- Max 36 macros per account
		if GetNumMacros() == 36 then
			DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99MageMealMacro|r: |cffff0000WARNING|r: Unable to create macro. Please free up a macro slot and reload your UI.")
			return
		end
		CreateMacro("MageMealMacro", "INV_MISC_QUESTIONMARK", "#showtooltip\n/cast [btn:2] Conjure Water\n/cast [mod:ctrl] Conjure Food\n/click MageMealMacro", nil)
	end
end

function MageMealMacro:HasDrinkAura()
  for i = 1, 16 do
    local aura, icon = UnitAura("player", i)
    if not aura or not icon then
      return false
    elseif AURAS[aura] or ICONS[icon] then
      return true
    end
  end
  return false
end

function MageMealMacro:Update()
	if UnitAffectingCombat("player") or not self.drink then return end
	if MageMealMacro:HasDrinkAura() then
		self:SetAttribute("macrotext", "/run MageMealMacro:Update()");
	else
		local macrotext = "/run MageMealMacro:Update()\n"
		if UnitPower("player")/UnitPowerMax("player") < mana_threshold and self.drink ~= nil then
			macrotext = macrotext .. "/use " .. self.drink .. "\n"
		end
		if UnitHealth("player")/UnitHealthMax("player") < health_threshold and self.food ~= nil then
			macrotext = macrotext .. "/use " .. self.food .. "\n"
		end
		self:SetAttribute("macrotext", macrotext)
	end
end

MageMealMacro:RegisterEvent("BAG_UPDATE")
function MageMealMacro:BAG_UPDATE()
	for i=1, #Foods do
		if GetItemCount(Foods[i]) > 0 then
			self.food = Foods[i]
			break
		end
	end
	for i=1, #Drinks do
		if GetItemCount(Drinks[i]) > 0 then
			self.drink = Drinks[i]
			if not UnitAffectingCombat("player") then
				SetMacroItem("MageMealMacro", Drinks[i])
				self:Update()
			end
			break
		end
	end
end

