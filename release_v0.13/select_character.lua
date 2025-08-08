-- 依次定字 + 记录用户实际上屏的文本
-- 来源修改自：https://github.com/BlindingDark/rime-lua-select-character
local function utf8_sub(s, i, j)
    i = i or 1
    j = j or -1

    if i < 1 or j < 1 then
        local n = utf8.len(s)
        if not n then return nil end
        if i < 0 then i = n + 1 + i end
        if j < 0 then j = n + 1 + j end
        if i < 0 then i = 1 elseif i > n then i = n end
        if j < 0 then j = 1 elseif j > n then j = n end
    end

    if j < i then return "" end

    i = utf8.offset(s, i)
    j = utf8.offset(s, j + 1)
    if i and j then
        return s:sub(i, j - 1)
    elseif i then
        return s:sub(i)
    else
        return ""
    end
end

local function first_character(s)
    return utf8_sub(s, 1, 1)
end

local function last_character(s)
    return utf8_sub(s, -1, -1)
end

local function get_commit_text(context, fun)
    local candidate_text = context:get_selected_candidate().text
    local selected_character = fun(candidate_text)

    context:clear_previous_segment()
    local commit_text = context:get_commit_text()
    context:clear()

    return commit_text .. selected_character
end


-- 新增：删除文件最后一个字符（支持空格等ASCII字符和中文）
local function delete_last_character(filepath)
    local file = io.open(filepath, "r")
    if not file then return end

    local content = file:read("*a")
    file:close()

    if content == "" then return end  -- 如果文件为空，直接返回

    -- 使用UTF-8迭代器找到最后一个字符的位置
    local last_char_pos = 1
    for pos in utf8.codes(content) do
        last_char_pos = pos
    end

    -- 截断到最后一个字符之前
    local new_content = content:sub(1, last_char_pos - 1)
    
    -- 写回文件
    file = io.open(filepath, "w")
    if file then
        file:write(new_content)
        file:close()
    end
end

-- 新增：初始化函数（监听提交事件）
local function init(env) -- 初始化模块的运行时环境，当 RIME 加载该 Lua 模块时自动调用（通常是在输入法启动或切换方案时）,类比开店前的准备工作，进货、布置柜台、打开收银系统
    env.last_commit_text = ""
    -- 连接提交通知器
    env.commit_notifier = env.engine.context.commit_notifier:connect(
        function(ctx)
            local commit_text = ctx:get_commit_text()
            if commit_text ~= "" then
                env.last_commit_text = commit_text
                -- 记录到文件
                local text_in_log_file = ""
                local log_file = io.open("D:\\For_Rime\\For_Rime_config\\rime_recent_chars.txt", "r")
                if log_file then
                    text_in_log_file = log_file:read("*a")
                    log_file:close()
                end

                local allowed_chars = {}
                local num_of_c = 0
                for _, code in utf8.codes(text_in_log_file) do
                    local c = utf8.char(code)
                    if (code == 0x20) or (code >= 0x3400 and code <= 0x9FFF) or (code >= 13312 and code <= 40870) or c:match("%w") or c:match("%p") or c:match("%d") then -- 把空格也算进来，因为空格被用来标记用户打的换行了，现在删除换行会删除这个空格，而不会删掉用户打的文字了
                        table.insert(allowed_chars, c)
                        num_of_c = num_of_c + 1
                    end
                end

                if num_of_c > 30 then
                    local last_30 = {}
                    for i = num_of_c - 30, num_of_c do
                        table.insert(last_30, allowed_chars[i])
                    end
                    local new_content = table.concat(last_30)
                    local file = io.open("D:\\For_Rime\\For_Rime_config\\rime_recent_chars.txt", "w")
                    if file then
                        file:write(new_content)
                        file:close()
                    end
                end

                local test_file = io.open("D:\\For_Rime\\For_Rime_config\\rime_recent_chars.txt", "a")
                if test_file then
                    test_file:write(commit_text)
                    test_file:close()
                end
            end
        end
    )
end

-- 新增：清理函数
local function fini(env) -- 清理模块占用的资源，类比关店时的收尾工作，清点库存、关闭收银系统
    if env.commit_notifier then
        env.commit_notifier:disconnect()
    end
end

-- 主处理函数（保留原有逻辑）
local function select_character(key, env)
    local engine = env.engine
    local context = engine.context
    local config = engine.schema.config

   -- 检测删除键（Backspace 或 Delete）
    local actual_key = key:repr()


    -- 选择开头字
    local first_key = config:get_string('key_binder/select_first_character') or 'bracketleft'
    -- 选择末尾字
    local last_key = config:get_string('key_binder/select_last_character') or 'bracketright'

    local commit_text = context:get_commit_text()

    if (key:repr() == first_key and commit_text ~= "") then
        engine:commit_text(get_commit_text(context, first_character))
        return 1 -- kAccepted
    end

    if (key:repr() == last_key and commit_text ~= "") then
        engine:commit_text(get_commit_text(context, last_character))
        return 1 -- kAccepted
    end

    if (actual_key == "BackSpace" or actual_key == "Delete")  and commit_text == "" then
        delete_last_character("D:\\For_Rime\\For_Rime_config\\rime_recent_chars.txt")
      --   return 1  -- kAccepted
    end

    if actual_key == "space" and commit_text == "" then
      local test_file = io.open("D:\\For_Rime\\For_Rime_config\\rime_recent_chars.txt", "a")
      if test_file then
         test_file:write(" ")
         test_file:close()
      end
    end

   --  if actual_key == "Return" then
   --    local test_file = io.open("D:\\For_Rime\\For_Rime_config\\rime_recent_chars.txt", "a")
   --    if test_file then
   --       test_file:write(" ")
   --       test_file:close()
   --    end
   --  end
   
   --  if actual_key == "Return" and key:ctrl() then -- 单独检测Ctrl状态
   --     if actual_key == "Return" then
   --        local test_file = io.open("D:\\For_Rime\\For_Rime_config\\rime_recent_chars.txt", "a")
   --        if test_file then
   --           test_file:write(" ")
   --           test_file:close()
   --        end
   --     end
   --  end
    return 2 -- kNoop
end

-- 返回模块（新增 init 和 fini）
return {
    init = init, -- 告诉 RIME 初始化时调用这个函数
    fini = fini, -- 告诉 RIME 卸载时调用这个函数
    func = select_character -- 主处理函数
}