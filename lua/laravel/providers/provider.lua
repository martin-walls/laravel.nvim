-- a provider should have a register and a boot method
local provider = {}

---@param app LaravelApp
function provider:register(app)
  app:bindIf("api", "laravel.api")
  app:singeltonIf("env", "laravel.environment")
  app:bindIf("class", "laravel.services.class")

  -- SERVICES
  app:bindIf("artisan", "laravel.services.artisan")
  app:bindIf("commands", "laravel.services.commands")
  app:bindIf("composer", "laravel.services.composer")
  app:bindIf("configs", "laravel.services.configs")
  app:singeltonIf("history", "laravel.services.history")
  app:bindIf("paths", "laravel.services.paths")
  app:bindIf("php", "laravel.services.php")
  app:bindIf("routes", "laravel.services.routes")
  app:bindIf("views", "laravel.services.views")
  app:bindIf("runner", "laravel.services.runner")
  app:bindIf("ui_handler", "laravel.services.ui_handler")
  app:bindIf("view_finder", "laravel.services.view_finder")

  -- CACHE DECORATORS
  app:singeltonIf("cache_commands", function()
    return require("laravel.services.cache_decorator"):new(app("commands"))
  end)

  app:singeltonIf("cache_routes", function()
    return require("laravel.services.cache_decorator"):new(app("routes"))
  end)
end

---@param app LaravelApp
function provider:boot(app)
  app("env"):boot()

  require("laravel.treesitter_queries")

  local group = vim.api.nvim_create_augroup("laravel", {})

  vim.api.nvim_create_autocmd({ "DirChanged" }, {
    group = group,
    callback = function()
      app("env"):boot()
    end,
  })

  vim.api.nvim_create_autocmd({"User"}, {
    group = group,
    pattern = "LaravelCommandRun",
    callback = function(ev)
      app("history"):add(
        ev.data.job_id,
        ev.data.cmd,
        ev.data.args,
        ev.data.options
      )
    end,
  })
end

return provider
