describe("adf_utils", function()
    local utils = require("jirac.adf_utils")

    it("map single line", function ()
        assert.are_same(
        {
            version = 1,
            type = "doc",
            content = {{
                type = "paragraph",
                content = {{
                    type = "text",
                    text = "hello\n"
                }}
            }}
        },
            utils.format_to_adf("hello")
        )
    end)

    it("map two paragraphs", function ()
        assert.are_same(
        {
            version = 1,
            type = "doc",
            content = {{
                    type = "paragraph",
                    content = {{
                        type = "text",
                        text = "hello\n"
                    }}
                },
                {
                    type = "paragraph",
                    content = {{
                        type = "text",
                        text = "world\n"
                    }}
                }
            }
        },
            utils.format_to_adf("hello\n\nworld")
        )
    end)

    it("map two lines", function ()
        assert.are_same(
        {
            version = 1,
            type = "doc",
            content = {{
                    type = "paragraph",
                    content = {
                        {
                            type = "text",
                            text = "hello\n"
                        },
                        {
                            type = "text",
                            text = "world\n"
                        }
                    }
                }
            }
        },
            utils.format_to_adf("hello\nworld")
        )
    end)

    it("map empty string,", function ()
        assert.are_same(
        {
            version = 1,
            type = "doc",
            content = {{
                    type = "paragraph",
                    content = {
                        {
                            type = "text",
                            text = "\n"
                        }
                    }
                }
            }
        },
            utils.format_to_adf("")
        )
    end)

    it("map complex text", function ()
        assert.are_same(
        {
            version = 1,
            type = "doc",
            content = {{
                    type = "paragraph",
                    content = {
                        {
                            type = "text",
                            text = "Hello\n"
                        },
                        {
                            type = "text",
                            text = "world\n"
                        }
                    }
                },
                {
                    type = "paragraph",
                    content = {
                        {
                            type = "text",
                            text = "World\n"
                        },
                        {
                            type = "text",
                            text = "hello\n"
                        }
                    }
                }
            }
        },
            utils.format_to_adf("Hello\nworld\n\nWorld\nhello")
        )
    end)

    it("simple map to adf", function ()
        assert.are_equal(
            "hello",
            utils.format_to_text {
                content = {{
                    type = "paragraph",
                    content = {{
                        type = "text",
                        text = "hello"
                    }}
                }}
            }
        )
    end)

    it ("map to adf multiple paragraphs", function ()
        assert.are_equal(
        "hello\n\nworld",
        utils.format_to_text {
            content = {
                {
                    type = "paragraph",
                    content = {{
                        type = "text",
                        text = "hello"
                    }}
                },
                {
                    type = "paragraph",
                    content = {{
                        type = "text",
                        text = "world"
                    }}
                }
            }
        }
        )
    end)


    it ("map to adf multiple lines", function ()
        assert.are_equal(
        "hello\nworld",
        utils.format_to_text {
            content = {
                {
                    type = "paragraph",
                    content = {
                        {
                            type = "text",
                            text = "hello"
                        },
                        {
                            type = "text",
                            text = "world"
                        }
                    }
                },
            }
        }
        )
    end)

    it ("map to adf empty", function ()
        assert.are_equal(
        "",
        utils.format_to_text {
            content = {
                {
                    type = "paragraph",
                    content = {
                        {
                            type = "text",
                            text = ""
                        }
                    }
                }
            }
        })
    end)

    it ("map to adf complex", function ()
        assert.are_equal(
        "hello\nworld\n\nworld\nhello",
        utils.format_to_text {
            content = {
                {
                    type = "paragraph",
                    content = {
                        {
                            type = "text",
                            text = "hello"
                        },
                        {
                            type = "text",
                            text = "world"
                        }
                    }
                },
                {
                    type = "paragraph",
                    content = {
                        {
                            type = "text",
                            text = "world"
                        },
                        {
                            type = "text",
                            text = "hello"
                        }
                    }
                }
            }
        }
        )
    end)

end)
