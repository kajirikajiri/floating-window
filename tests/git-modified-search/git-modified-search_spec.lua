local module = require("git-modified-search.module")
local plugin = require("git-modified-search")

describe("plugin", function()
  before_each(function()
    vim.cmd("cd diffs")
  end)

  after_each(function()
    vim.cmd("cd ..")
    vim.fn.setqflist({}, " ", { size = 0 }) end)

  it("quickfixlistが2になること", function()
    assert("not error", plugin.modified_lines_to_quick_fix("HEAD~1 Hello world 5"))
    assert.are.equal(2, vim.fn.getqflist({ size = 0 }).size)
  end)
  it("quickfixlistが0になること", function()
    assert("not error", plugin.modified_lines_to_quick_fix("HEAD~1 Hello world 3"))
    assert.are.equal(0, vim.fn.getqflist({ size = 0 }).size)
  end)
end)

describe("module", function()
  before_each(function()
    vim.cmd("cd diffs")
  end)

  after_each(function()
    vim.cmd("cd ..")
  end)

  it("検索しない場合、変更した行を取得できること", function()
    assert.are.same({
      {
        filename = "add-line.txt",
        lnum = "5",
        text = "Hello world5",
      },
      {
        filename = "update-line.txt",
        lnum = "4",
        text = "Hello world5",
      },
    }, module.get_modified_lines("HEAD~1"))
  end)

  it("検索して見つからない場合、からのテーブルが返ること", function()
    assert.are.same({}, module.get_modified_lines("HEAD~1", "3"))
  end)

  it("検索して見つかる場合、テーブルが返ること", function()
    assert.are.same({
      {
        filename = "add-line.txt",
        lnum = "5",
        text = "Hello world5",
      },
      {
        filename = "update-line.txt",
        lnum = "4",
        text = "Hello world5",
      },
    }, module.get_modified_lines("HEAD~1", "world"))
  end)

  it(
    "空白区切りの文字列の場合、空白で分割した全ての文字列を検索して全て見つかる場合、テーブルが返ること",
    function()
      assert.are.same({
        {
          filename = "add-line.txt",
          lnum = "5",
          text = "Hello world5",
        },
        {
          filename = "update-line.txt",
          lnum = "4",
          text = "Hello world5",
        },
      }, module.get_modified_lines("HEAD~1", "Hello world 5"))
    end
  )

  it(
    "空白区切りの文字列の場合、空白で分割した全ての文字列を検索して１つでも見つからない場合、からのテーブルが返ること",
    function()
      assert.are.same({}, module.get_modified_lines("HEAD~1", "Hello world 3"))
    end
  )

  it("正規表現で検索して見つかる場合、テーブルが返ること", function()
    assert.are.same({
      {
        filename = "add-line.txt",
        lnum = "5",
        text = "Hello world5",
      },
      {
        filename = "update-line.txt",
        lnum = "4",
        text = "Hello world5",
      },
    }, module.get_modified_lines("HEAD~1", "^H.*5$"))
  end)

  it("正規表現で検索して見つからない場合、からのテーブルが返ること", function()
    assert.are.same({}, module.get_modified_lines("HEAD~1", "^H.*3$"))
  end)
end)
