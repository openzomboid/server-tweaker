--
-- Copyright (c) 2024 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

require "ISUI/ISPanel"

DatabaseModifyRow = ISPanel:derive("DatabaseModifyRow");

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

function DatabaseModifyRow:initialise()
    ISPanel.initialise(self);
end

function DatabaseModifyRow:render()
    ISPanel.render(self);
    local z = 10;
    self:drawText(getText("IGUI_DbViewer_ModifyRow"), self.width/2 - (getTextManager():MeasureStringX(UIFont.Medium, getText("IGUI_DbViewer_ModifyRow")) / 2), z, 1,1,1,1, UIFont.Medium);

    local xoff = 10;
    local yoff = z + FONT_HGT_MEDIUM + 10;
    local rowHgt = FONT_HGT_SMALL + 2 * 2
    self:drawRectBorder(xoff, yoff, self.width - 20, rowHgt, 1, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    self:drawRect(xoff, yoff, self.width - 20, rowHgt, self.listHeaderColor.a, self.listHeaderColor.r, self.listHeaderColor.g, self.listHeaderColor.b);
    local x = 0;

    for name, type in pairs(self.columns) do
        self:drawRect(xoff + x, 1 + yoff, 1, rowHgt - 1, 1, self.borderColor.r, self.borderColor.g, self.borderColor.b);

        self:drawText(type["name"], xoff + x + 10, yoff + 1, 1,1,1,1,UIFont.Small);
        if self.columnSize[type["name"]] then
            x = x + self.columnSize[type["name"]];
        else
            x = x + 100;
        end
    end
end

function DatabaseModifyRow:new(x, y, width, height, view, clear)
    local o = {};

    if x == 0 and y == 0 then
        x = (getCore():getScreenWidth() / 2) - (width / 2);
        y = (getCore():getScreenHeight() / 2) - (height / 2);
    end

    o = ISPanel:new(x, y, width, height);
    setmetatable(o, self);
    o.schema = {};
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    o.listHeaderColor = {r=0.4, g=0.4, b=0.4, a=0.3};
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5};
    o.backgroundColor = {r=0, g=0, b=0, a=0.8};
    o.tableName = view.tableName;
    o.columns = view.columns;
    o.columnSize = view.columnSize;
    o.data = view.datas.items[view.datas.selected].item.datas;
    o.moveWithMouse = true;
    o.buttonDatas = {};
    o.view = view;
    o.entriesPerPages = view.entriesPerPages;
    o.clear = clear

    return o;
end

function DatabaseModifyRow:createChildren()
    ISPanel.createChildren(self);

    local btnWid = 100
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local padBottom = 10
    local width = 10

    for _, type in pairs(self.columns) do
        local size = self.columnSize[type["name"]] + 1;
        width = width + size
    end

    self:setWidth(width + 10)

    self.close = ISButton:new(self:getWidth() - 100 - 10, 0, btnWid, btnHgt, getText("IGUI_CraftUI_Close"), self, DatabaseModifyRow.onOptionMouseDown);
    self.close.internal = "CLOSE";
    self.close:initialise();
    self.close:instantiate();
    self.close.borderColor = self.buttonBorderColor;
    self:addChild(self.close);

    self.Update = ISButton:new(10, 0, btnWid, btnHgt, getText("IGUI_DbViewer_Update"), self, DatabaseModifyRow.onOptionMouseDown);
    self.Update.internal = "UPDATE";
    self.Update:initialise();
    self.Update:instantiate();
    self.Update.borderColor = self.buttonBorderColor;
    self:addChild(self.Update);

    local x = 10;
    local y = 10 + FONT_HGT_MEDIUM + 10 + FONT_HGT_SMALL + 2 * 2
    local entryHgt = FONT_HGT_MEDIUM + 2 * 2

    for _, type in pairs(self.columns) do
        local size = self.columnSize[type["name"]] + 1;
        if _ == #self.columns then
            size = self.width - x - 10;
        end

        if type["type"] == "TEXT" or type["type"] == "INTEGER" or type["type"] == "JSON" then
            if self.clear then
                self.entry = ISTextEntryBox:new("", x, y, size, entryHgt);
            else
                self.entry = ISTextEntryBox:new(self.data[type["name"]], x, y, size, entryHgt);
            end
            self.entry.font = UIFont.Medium
            self.entry:initialise();
            self.entry:instantiate();
            self.entry.columnName = type["name"];
            self.entry.type = type["type"];

            if type["type"] == "INTEGER" then
                self.entry:setOnlyNumbers(true);
            end

            self:addChild(self.entry);
            table.insert(self.buttonDatas, self.entry);
        elseif type["type"] == "BOOLEAN" then
            self.combo = ISComboBox:new(x, y, size, entryHgt, nil,nil);
            self.combo.font = UIFont.Medium
            self.combo:initialise();
            self:addChild(self.combo);
            self.combo:addOption("true");
            self.combo:addOption("false");

            if self.data[type["name"]] == "false" or self.data[type["name"]] == "0" then
                self.combo.selected = 2;
            end

            self.combo.type = type["type"];
            self.combo.columnName = type["name"];
            table.insert(self.buttonDatas, self.combo);
        end

        x = x + self.columnSize[type["name"]];
    end

    self.close:setY(y + entryHgt + 20)
    self.Update:setY(self.close.y)
    self:setHeight(self.close:getBottom() + padBottom)
end

function DatabaseModifyRow:onOptionMouseDown(button, x, y)
    if button.internal == "CLOSE" then
        self:setVisible(false);
        self:removeFromUIManager();
    end

    if button.internal == "UPDATE" then
        local key = self.buttonDatas[1]:getText();
        local value = self.buttonDatas[2]:getText();

        if key ~= "" and value ~= "" then
            if self.buttonDatas[2].type == "JSON" then
                value = openutils.ConvertJsonToTable(value)
            end

            LuaDatabaseClient.buckets[self.tableName].Save(key, value)
        end

        self.view:clear();
        LuaDatabaseClient.buckets[self.tableName].GetFromServer("DatabaseListTable")
        self:setVisible(false);
        self:removeFromUIManager();
    end
end
