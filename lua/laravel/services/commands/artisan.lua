---@class ArtisanCommand
---@field runner LaravelRunner
---@field api LaravelApi
---@field cache LaravelCache
---@field pickers LaravelPickersManager
local artisan = {}

function artisan:new(runner, api, cache, pickers)
  local instance = {
    runner = runner,
    api = api,
    cache = cache,
    pickers = pickers,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function artisan:commands()
  return { "artisan", "art" }
end

function artisan:handle(args)
  table.remove(args.fargs, 1)
  if vim.tbl_isempty(args.fargs) then
    if self.pickers:exists('artisan') then
      self.pickers:run('artisan')
      return
    end
  end

  self.runner:run("artisan", args.fargs)
end

function artisan:complete(argLead)
  local commands = self.cache:remember("laravel-commands", 60, function()
    local resp = {}
    self.api:async("artisan", { "list", "--format=json" }, function(result)
      resp = result
    end):wait()

    if resp:failed() then
      return {}
    end

    return vim.tbl_filter(function(cmd)
      return not cmd.hidden
    end,resp:json().commands)
  end)

  return vim
      .iter(commands)
      :map(function(cmd)
        return cmd.name
      end)
      :filter(function(name)
        return vim.startswith(name, argLead)
      end)
      :totable()
end

return artisan
