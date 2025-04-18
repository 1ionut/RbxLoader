local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Loader = {
    Util = {
        Promise = require(ReplicatedStorage.Packages.Promise),
    }
}
local m_Components = {}
local m_Started = false

local Promise = Loader.Util.Promise
local Signal = Loader.Util.Signal

function Loader.AddComponents(source : Instance)
    for _, component in pairs(source:GetChildren()) do
        if not component:IsA("ModuleScript") then continue end
        component = require(component)
        local name = component.Name
        assert(name, "Missing name property")
        m_Components[name] = component
    end
end

local function Init()
    return Promise.new(function(Resolve, Reject)
        for name, component in pairs(m_Components) do
            local init = component["OnInit"]
            if not init then continue end
            if typeof(init) ~= "function" then continue end
            init()
        end
        Resolve()
    end)
end

local function Start()
    for name, component in pairs(m_Components) do
        local init = component["OnStart"]
        if not init then continue end
        if typeof(init) ~= "function" then continue end
        init()
    end
end

function Loader.Start()
    return Promise.new(function(Resolve, Reject)
        local success, response = Init()
        if not success then
           Reject(response)
        end

        Start()
        Resolve()
    end)
end

return Loader