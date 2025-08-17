-- Stats API (v1.0)
-- Copyright (c) 2022, Jericho Crosby <jericho.crosby227@gmail.com>

return {

    -- File that contains the user accounts:
    --
    file = './Stats API/stats.json',


    -- If a user doesn't log into an account after this many days, it's considered
    -- stale and will be deleted:
    delete_stale_accounts = true,
    stale_account_period = 10,


    -- Account management commands:
    account_management_syntax = { "account", "create", "login" }
}