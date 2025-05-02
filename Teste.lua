-- SpectreExecutor v1.0 - Executor Fantasmagórico
local SpectreExecutor = {
    _version = "1.0.0",
    _spirits = {}, -- Tarefas/scripts armazenados
    _currentRitual = nil, -- Execução atual
    _darkEnergy = 0, -- Recursos disponíveis
    _maxEnergy = 100,
    _curses = {} -- Erros/avisos
}

-- Métodos místicos
local Necronomicon = {
    ["Invocation"] = function(code)
        return loadstring(code)
    end,
    ["Banishing"] = function(err)
        table.insert(SpectreExecutor._curses, err)
    end
}

--[[
    Conjura um novo script para ser executado
    @param spiritName: Nome do espírito/script
    @param incantation: Código Lua a ser executado
    @param priority: Nível de prioridade (1-10)
]]
function SpectreExecutor.ConjureSpirit(spiritName, incantation, priority)
    local spirit = {
        name = spiritName,
        code = incantation,
        priority = priority or 5,
        bound = false
    }
    
    SpectreExecutor._spirits[spiritName] = spirit
    return string.format("🌀 Espírito %s conjurado (Prioridade: %d)", spiritName, priority)
end

--[[
    Inicia o ritual de invocação
    @param spiritName: Nome do espírito a invocar
]]
function SpectreExecutor.InvokeSpirit(spiritName)
    local spirit = SpectreExecutor._spirits[spiritName]
    if not spirit then
        return "⛤ Espírito não encontrado no grimório"
    end
    
    if SpectreExecutor._currentRitual then
        return "✖ Já existe um ritual em andamento"
    end
    
    SpectreExecutor._currentRitual = spiritName
    local success, err = pcall(function()
        local fn = Necronomicon.Invocation(spirit.code)
        if fn then fn() end
    end)
    
    SpectreExecutor._currentRitual = nil
    
    if not success then
        Necronomicon.Banishing(err)
        return string.format("☠ Maldição lançada durante a invocação: %s", err)
    end
    
    return string.format("☑ Espírito %s invocado com sucesso", spiritName)
end

--[[
    Libera um espírito/conjuração
    @param spiritName: Nome do espírito a ser liberado
]]
function SpectreExecutor.ReleaseSpirit(spiritName)
    if SpectreExecutor._spirits[spiritName] then
        SpectreExecutor._spirits[spiritName] = nil
        return string.format("♻ Espírito %s liberado", spiritName)
    end
    return "⛤ Espírito não encontrado"
end

--[[
    Lista todos os espíritos conjurados
]]
function SpectreExecutor.ListSpectres()
    local list = "📜 Grimório de Espíritos:\n"
    for name, spirit in pairs(SpectreExecutor._spirits) do
        list += string.format("- %s (Prioridade: %d)\n", name, spirit.priority)
    end
    return list
end

return SpectreExecutor
