local service = require "jirac.jira_user_service"

for _, v in ipairs(service.get_all_users()) do
    print(v.displayName, v.accountId)
end
