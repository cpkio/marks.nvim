local has_sqlite, sqlite = pcall(require, 'sqlite')
local utils = require'marks.utils'

local storage = sqlite {
  uri = vim.fn.expand('~') .. '/marks.db',
  bookmarks = {
    _id = true,
    filename = 'text',
    line = 'int',
    bookmark_group = 'int',
    annotation = 'text'
  }
}

local bm = storage.bookmarks

local M = {}

function M.new()
  return setmetatable({}, { __index = M })
end

function M:save_mark(group, line, text) -- сохранение закладки
  local m = bm:get{ where = {
    filename = utils.path_unify(vim.api.nvim_buf_get_name(0)),
    line = line,
  }}
  if text == nil then text = '' end
  if m ~= nil and #m == 1 then
    bm:update{
      filename = utils.path_unify(vim.api.nvim_buf_get_name(0)),
      line = line,
      bookmark_group = group,
      annotation = text
    }
  else
    bm:insert{
      filename = utils.path_unify(vim.api.nvim_buf_get_name(0)),
      line = line,
      bookmark_group = group,
      annotation = text
    }
  end
end

function M:annotate(group, line, text)
  bm:update{
    where = {
      filename = utils.path_unify(vim.api.nvim_buf_get_name(0)),
      bookmark_group = group,
      line = line
    },
    set = {
      annotation = text
    }
  }
end

function M:load_marks(file) -- загрузка всех закладок вместе с файлом
  return bm:get{
      where = { filename = file }
  }
end

function M:delete_mark(group, line) -- удаление закладки
  bm:remove{ where = {
      filename = utils.path_unify(vim.api.nvim_buf_get_name(0)),
      bookmark_group = group,
      line = line
    }
  }
end

function M:delete_marks(group) -- удаление всех закладок
  bm:remove{ where = {
      filename = utils.path_unify(vim.api.nvim_buf_get_name(0)),
      bookmark_group = group
    }
  }
end

return M