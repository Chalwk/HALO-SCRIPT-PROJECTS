-- Alias System [Settings File] (v1.0)
-- Copyright (c) 2022, Jericho Crosby <jericho.crosby227@gmail.com>

return {

    -- File that contains the json database of aliases:
    -- This file will be created in 'cg/sapp/'
    --
    file = 'aliases.json',


    -- Base command:
    --
    command = 'alias',


    -- Minimum permission required to execute /command:
    --
    permission = 1,


    -- If true, the .json database will be updated
    -- every time a player joins.
    --
    -- If false, the .json database will only be updated
    -- when the game ends (recommended).
    --
    update_file_on_join = false,


    -- If a player hasn't connected with a specific hash or ip
    -- after this many days, it's considered stale and will be deleted:
    --
    delete_stale_records = true,
    stale_period = 30,


    -- When executing /alias <pid>, what should the default look up table be?
    -- Valid Tables: 'ip_addresses' or 'hashes'
    --
    default_table = 'ip_addresses',


    -- IP-alias lookup flag:
    ip_lookup_flag = '-ip',


    -- Hash-alias lookup flag:
    hash_lookup_flag = '-hash',


    --------------------------------------------------------------------------
    -- Advanced users only:
    --
    --
    -- Max results to load per page:
    max_results = 50,


    -- Aliases are printed in columns of 5:
    max_columns = 5,


    -- Spacing between names per column:
    spaces = 2,


    -- List of all known pirated hashes:
    -- If someone has a pirated hash, the script will tell you upon querying the hash:
    --
    known_pirated_hashes = {
        ['388e89e69b4cc08b3441f25959f74103'] = true,
        ['81f9c914b3402c2702a12dc1405247ee'] = true,
        ['c939c09426f69c4843ff75ae704bf426'] = true,
        ['13dbf72b3c21c5235c47e405dd6e092d'] = true,
        ['29a29f3659a221351ed3d6f8355b2200'] = true,
        ['d72b3f33bfb7266a8d0f13b37c62fddb'] = true,
        ['76b9b8db9ae6b6cacdd59770a18fc1d5'] = true,
        ['55d368354b5021e7dd5d3d1525a4ab82'] = true,
        ['d41d8cd98f00b204e9800998ecf8427e'] = true,
        ['c702226e783ea7e091c0bb44c2d0ec64'] = true,
        ['f443106bd82fd6f3c22ba2df7c5e4094'] = true,
        ['10440b462f6cbc3160c6280c2734f184'] = true,
        ['3d5cd27b3fa487b040043273fa00f51b'] = true,
        ['b661a51d4ccf44f5da2869b0055563cb'] = true,
        ['740da6bafb23c2fbdc5140b5d320edb1'] = true,
        ['7503dad2a08026fc4b6cfb32a940cfe0'] = true,
        ['4486253cba68da6786359e7ff2c7b467'] = true,
        ['f1d7c0018e1648d7d48f257dc35e9660'] = true,
        ['40da66d41e9c79172a84eef745739521'] = true,
        ['2863ab7e0e7371f9a6b3f0440c06c560'] = true,
        ['34146dc35d583f2b34693a83469fac2a'] = true,
        ['b315d022891afedf2e6bc7e5aaf2d357'] = true,
        ['63bf3d5a51b292cd0702135f6f566bd1'] = true,
        ['6891d0a75336a75f9d03bb5e51a53095'] = true,
        ['325a53c37324e4adb484d7a9c6741314'] = true,
        ['0e3c41078d06f7f502e4bb5bd886772a'] = true,
        ['fc65cda372eeb75fc1a2e7d19e91a86f'] = true,
        ['f35309a653ae6243dab90c203fa50000'] = true,
        ['50bbef5ebf4e0393016d129a545bd09d'] = true,
        ['a77ee0be91bd38a0635b65991bc4b686'] = true,
        ['3126fab3615a94119d5fe9eead1e88c1'] = true,
    }
}