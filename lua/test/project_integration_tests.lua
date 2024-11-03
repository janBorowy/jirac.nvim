local service = require("jirac.jira_project_service")

-- P(service.get_project_types())

-- P(service.get_project_categories())

-- local result, obj = pcall(service.create_project, {
--     key="BACK",
--     name="Backend Development a",
--     projectTypeKey="business",
--     description="Build our backend here",
--     url="https://google.com",
--     leadAccountId="712020:cfc3fbdf-e877-49e8-8a3a-7b831b9dbabf"
-- })

local result, obj = pcall(service.update_project,
    "BACK",
{
    key = "BD",
    name = "BACK DEV", 
    description = "Hello"
})

-- local result, obj = pcall(service.delete_project, "BD")
-- local result, obj = pcall(service.archive_project, "BACK")

if result then
    P("success")
else
    P(obj)
end
