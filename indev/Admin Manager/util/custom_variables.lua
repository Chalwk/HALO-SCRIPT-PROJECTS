--
-- Credits to @edgardanielgd for this class.
-- > https://github.com/edgardanielgd
--

local variables = {}

function variables:registerLevelVariable()
    execute_command('var_add '
            .. self.custom_level_var
            .. ' 4'
    )
end

function variables:unregisterLevelVariable()
    execute_command('var_del '
            .. self.custom_level_var
    )
end

function variables:setLevelVariable()
    execute_command('var_set '
            .. self.custom_level_var
            .. ' ' .. self.level
            .. ' ' .. self.id
    )
end

return variables