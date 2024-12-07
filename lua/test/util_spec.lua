describe("utils", function()
    local utils = require("jirac.util")

    it("wrap exactly fitting word", function ()
        assert.are_same({"hello"}, utils.wrap_string("hello", 5))
    end)

    it("wrap word smaller than line", function ()
        assert.are_same({"hello "}, utils.wrap_string("hello", 6))
    end)


    it("wrap word longer than a line", function ()
        assert.are_same({"hello"}, utils.wrap_string("hello", 4))
    end)

    it("wrap varying text", function ()
        assert.are_same({"this is a ", "looooooooong", "text "},
        utils.wrap_string("this is a looooooooong text", 10))
    end)

end)

