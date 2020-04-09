-- Copyright (c) 2020 Kirazy
-- Part of Vanilla Loaders HD: Krastorio
--     
-- See LICENSE.md in the project directory for license information.

-- ###################################################################################
-- Library functions and tables to be removed when the Reskins Library mod is published

-- Mapping of particles to short name
local particle_index = 
{
    ["medium"] = "metal-particle-medium",
    ["big"] = "metal-particle-big",
}

-- Converts hex code values to rgb values
local function tint_hex_to_rgb(hex)
    hex = hex:gsub("#","")
    tint = {tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))}
    return tint
end

-- Adjusts alpha values for a given tint
local function adjust_alpha(tint, alpha)
    adjusted_tint = {tint[1], tint[2], tint[3], alpha*255}
    return adjusted_tint
end

-- Create explosion; assign particles after calling this function
local function create_explosion(name, inputs)
    -- Inputs expected by this function:
    -- base_entity - Entity to copy explosion prototype from
    -- type        - Entity type

    -- Copy explosion prototype
    local explosion = table.deepcopy(data.raw["explosion"][inputs.base_entity.."-explosion"])
    explosion.name = name.."-explosion"
    data:extend({explosion})

    -- Assign explosion to originating entity
    data.raw[inputs.type][name]["dying_explosion"] = explosion.name
end

-- Create tinted particle
local function create_particle(name, base_entity, base_particle, key, tint)
    -- Copy the particle prototype
    local particle = table.deepcopy(data.raw["optimized-particle"][base_entity.."-"..base_particle])
    particle.name = name.."-"..base_particle.."-tinted"
    particle.pictures.sheet.tint = tint
    particle.pictures.sheet.hr_version.tint = tint
    data:extend({particle})

    -- Assign particle to originating explosion
    data.raw["explosion"][name.."-explosion"]["created_effect"]["action_delivery"]["target_effects"][key].particle_name = particle.name
end

-- Handle icon assignment
local function assign_icons(name, inputs)
    -- Inputs required by this function
    -- type            - Entity type
    -- icon            - Table or string defining icon
    -- icon_size       - Pixel size of icons
    -- icon_mipmaps    - Number of mipmaps present in the icon image file

    -- Initialize paths
    local entity = data.raw[inputs.type][name]
    local item = data.raw["item"][name]
    local explosion = data.raw["explosion"][name.."-explosion"]
    local remnant = data.raw["corpse"][name.."-remnants"]

    -- Check whether icon or icons, ensure the key we're not using is erased
    if type(inputs.icon) == "table" then
        -- Create icons that have multiple layers
        if entity then
            entity.icon = nil        
            entity.icons = inputs.icon
        end

        if item then
            item.icon = nil
            item.icons = inputs.icon
        end

        if explosion then 
            explosion.icon = nil        
            explosion.icons = inputs.icon
        end

        if remnant then
            remnant.icon = nil
            remnant.icons = inputs.icon
        end
    else
        -- Create icons that do not have multiple layers
        if entity then
            entity.icons = nil
            entity.icon = inputs.icon
        end

        if item then
            item.icons = nil        
            item.icon = inputs.icon
        end

        if explosion then
            explosion.icons = nil        
            explosion.icon = inputs.icon
        end

        if remnant then
            remnant.icons = nil
            remnant.icon = inputs.icon
        end
    end

    -- Make assignments common to all cases
    if entity then
        entity.icon_size = inputs.icon_size
        entity.icon_mipmaps = inputs.icon_mipmaps          
    end

    if item then
        item.icon_size = inputs.icon_size
        item.icon_mipmaps = inputs.icon_mipmaps 
    end

    if explosion then
        explosion.icon_size = inputs.icon_size
        explosion.icon_mipmaps = inputs.icon_mipmaps
    end
    
    if remnant then
        remnant.icon_size = inputs.icon_size
        remnant.icon_mipmaps = inputs.icon_mipmaps
    end
end

-- ###################################################################################
-- Reskin Krastorio's loaders

local inputs = 
{
	type = "loader-1x1",
	icon_size = 64,
	icon_mipmaps = 1,
	base_entity = "splitter",
	particles = {["big"] = 4, ["medium"] = 1},
	directory = "__krastorio-vanilla-loaders__",
}

local loader_map =
{
	["kr-loader"] 		   = {1, "ffc340"},
	["kr-fast-loader"] 	   = {2, "e31717"},
	["kr-express-loader"]  = {3, "43c0fa"},
	["kr-advanced-loader"] = {4, "3ade21"},
	["kr-superior-loader"] = {5, "a30bd6"},
}

-- Reskin entities, create and assign extra details
for name, map in pairs(loader_map) do
	-- Fetch entity
	entity = data.raw[inputs.type][name]

	-- Check if entity exists, if not, skip this iteration
    if not entity then
        goto continue
    end

	-- Prase map
	tier = map[1]
	inputs.tint = adjust_alpha(tint_hex_to_rgb(map[2]), 0.82)

	-- Create explosions. Big ones. The biggest explosions. Make Michael Bay proud!
	create_explosion(name, inputs)
        
	-- Create and assign needed particles with appropriate tints
	for particle, key in pairs(inputs.particles) do 
		-- Create and assign the particle
		create_particle(name, inputs.base_entity, particle_index[particle], key, adjust_alpha(inputs.tint, 1)) 
	end

	-- Reskin icons
	inputs.icon  = 
	{
		{
			icon = inputs.directory.."/graphics/icons/loader-icon-base.png"
		},
		{
			icon = inputs.directory.."/graphics/icons/loader-icon-mask.png",
			tint = inputs.tint
		}
	}

	item = data.raw["item"][name]

	item.pictures = 
	{
		{
			layers =
			{
				{
					filename = inputs.directory.."/graphics/icons/loader-icon-base.png",
					size = 64,
					scale = 0.25,
					mipmap_count = 1,
				},
				{
					filename = inputs.directory.."/graphics/icons/loader-icon-mask.png",
					size = 64,
					scale = 0.25,
					mipmap_count = 1,
					tint = inputs.tint,
				}
			}
		}
	}
	
	assign_icons(name, inputs)	

	-- Reskin entity, clearing existing sheet
	entity.structure.direction_in.sheet = nil
	entity.structure.direction_out.sheet = nil

	-- Set new sheets
	entity.structure.direction_in.sheets = 
	{
		-- Base
		{
			filename = inputs.directory.."/graphics/entity/loader/loader-structure-base.png",				
			width    = 96,
			height   = 96,
			y        = 0,
			hr_version = 
			{
				filename = inputs.directory.."/graphics/entity/loader/hr-loader-structure-base.png",
				height   = 192,
				priority = "extra-high",
				scale    = 0.5,
				width    = 192,
				y        = 0
			}
		},
		-- Mask
		{
			filename = inputs.directory.."/graphics/entity/loader/loader-structure-mask.png",			
			width    = 96,
			height   = 96,
			y        = 0,
			tint	 = inputs.tint,
			hr_version = 
			{
				filename = inputs.directory.."/graphics/entity/loader/hr-loader-structure-mask.png",
				height   = 192,
				priority = "extra-high",
				scale    = 0.5,
				width    = 192,
				y        = 0,
				tint     = inputs.tint,
			}
		},
		-- Shadow
		{
			filename = inputs.directory.."/graphics/entity/loader/loader-structure-shadow.png",			
			draw_as_shadow = true,
			width    = 96,
			height   = 96,
			y        = 0,
			hr_version = 
			{
				filename = inputs.directory.."/graphics/entity/loader/hr-loader-structure-shadow.png",
				draw_as_shadow = true,
				height   = 192,
				priority = "extra-high",
				scale    = 0.5,
				width    = 192,
				y        = 0,
			}
		}
	}

	entity.structure.direction_out.sheets = 
	{
		-- Base
		{
			filename = inputs.directory.."/graphics/entity/loader/loader-structure-base.png",			
			width    = 96,
			height   = 96,
			y        = 96,
			hr_version = 
			{
				filename = inputs.directory.."/graphics/entity/loader/hr-loader-structure-base.png",
				height   = 192,
				priority = "extra-high",
				scale    = 0.5,
				width    = 192,
				y        = 192
			}
		},
		-- Mask
		{
			filename = inputs.directory.."/graphics/entity/loader/loader-structure-mask.png",			
			width    = 96,
			height   = 96,
			y        = 96,
			tint	 = inputs.tint,
			hr_version = 
			{
				filename = inputs.directory.."/graphics/entity/loader/hr-loader-structure-mask.png",
				height   = 192,
				priority = "extra-high",
				scale    = 0.5,
				width    = 192,
				y        = 192,
				tint     = inputs.tint
			}
		},
		-- Shadow
		{
			filename = inputs.directory.."/graphics/entity/loader/loader-structure-shadow.png",			
			width    = 96,
			height   = 96,
			y        = 96,
			draw_as_shadow = true,
			hr_version = 
			{
				filename = inputs.directory.."/graphics/entity/loader/hr-loader-structure-shadow.png",
				height   = 192,
				priority = "extra-high",
				scale    = 0.5,
				width    = 192,
				y        = 192,
				draw_as_shadow = true,
			}
		}
	}

	-- Add back flange beneath items on the belt
	entity.structure.back_patch =
	{
		sheet =
		{
			filename = inputs.directory.."/graphics/entity/loader/loader-structure-back-patch.png",
			priority = "extra-high",
			width = 96,
			height = 96,
			hr_version =
			{
				filename = inputs.directory.."/graphics/entity/loader/hr-loader-structure-back-patch.png",
				priority = "extra-high",
				width = 192,
				height = 192,
				scale = 0.5
			}
		}
	}

	-- Add front patch, beneath entities on the tile below
	entity.structure.front_patch =
	{
		sheet =
		{
			filename = inputs.directory.."/graphics/entity/loader/loader-structure-front-patch.png",
			priority = "extra-high",
			width = 96,
			height = 96,
			hr_version =
			{
				filename = inputs.directory.."/graphics/entity/loader/hr-loader-structure-front-patch.png",
				priority = "extra-high",
				width = 192,
				height = 192,
				scale = 0.5
			}
		}
	}

	-- Label to skip to next iteration
    ::continue::
end