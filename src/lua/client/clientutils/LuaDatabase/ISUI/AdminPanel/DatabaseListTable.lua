--
-- Copyright (c) 2024 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

local logger = ConsoleLogger.new()

require "ISUI/ISPanel"

DatabaseListTable = ISPanel:derive("DatabaseListTable");

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2

function DatabaseListTable:new(x, y, width, height, tableName)
    local o = ISPanel:new(x, y, width, height);
    o.tableName = tableName;
    setmetatable(o, self);
    o.schema = {};
    o.pages = {};
    o.fullPages = {};
    o.listHeaderColor = {r=0.4, g=0.4, b=0.4, a=0.3};
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=0};
    o.backgroundColor = {r=0, g=0, b=0, a=1};
    o.columnSize = {};
    o.currentPage = 1;
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5};
    o.filters = {};
    o.filtered = false;
    o.totalResult = 0;
    o.entriesPerPages = 500;
    DatabaseListTable.instance = o;

    return o;
end

function DatabaseListTable:initialise()
    ISPanel.initialise(self);
end

function DatabaseListTable:render()
    ISPanel.render(self);

    self:drawRectBorder(self.datas.x, self.datas.y - HEADER_HGT, self.datas:getWidth(), HEADER_HGT + 1, 1, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    self:drawRect(self.datas.x, self.datas.y - HEADER_HGT, self.datas:getWidth(), HEADER_HGT + 1, self.listHeaderColor.a, self.listHeaderColor.r, self.listHeaderColor.g, self.listHeaderColor.b);
    local x = 0;

    for name, type in pairs(self.columns) do
        self:drawRect(self.datas.x + x, 1 + self.datas.y - HEADER_HGT, 1, HEADER_HGT,1,self.borderColor.r, self.borderColor.g, self.borderColor.b);

        self:drawText(type["name"], self.datas.x + x + 8, self.datas.y - HEADER_HGT + 2, 1,1,1,1,UIFont.Medium);
        if self.columnSize[type["name"]] then
            x = x + self.columnSize[type["name"]];
        else
            x = x + 100;
        end
    end

    local y = self.datas.y + self.datas.height + 5
    self:drawText(getText("IGUI_DbViewer_TotalResult") .. self.totalResult, 10, y, 1,1,1,1,UIFont.Small)
    y = y + FONT_HGT_SMALL

    if #self.datas.items > 0 or self.filtered then
        self:drawText(getText("IGUI_DbViewer_Filters"), 10, y, 1,1,1,1,UIFont.Large);
        y = y + FONT_HGT_LARGE
    end

    x = 10;

    if #self.datas.items > 0 or self.filtered then
        self:drawRectBorder(self.datas.x, y, self.datas:getWidth(), FONT_HGT_SMALL + 1, 1, self.borderColor.r, self.borderColor.g, self.borderColor.b);
        self:drawRect(self.datas.x, y, self.datas:getWidth(), FONT_HGT_SMALL + 1, self.listHeaderColor.a, self.listHeaderColor.r, self.listHeaderColor.g, self.listHeaderColor.b);
    end

    local nbr = 1;

    for _, v in ipairs(self.filters) do
        if #self.datas.items > 0 or self.filtered  then
            v:setY(y + FONT_HGT_SMALL)
            v:setVisible(true);

            if self.columnSize[v.columnName] then
                local size = self.columnSize[v.columnName] + 1
                if nbr >= #self.columns then
                    size = self.width - x - 10;
                end
                self:drawText(v.columnName, x + 10, y, 1,1,1,1,UIFont.Small);
                self:drawRectBorder(self.datas.x + x - 10, y, 1, self.datas.itemheight + 1, 1, self.borderColor.r, self.borderColor.g, self.borderColor.b);
                v:setWidth(size)
                v:setX(x);
                x = x + self.columnSize[v.columnName];
                nbr = nbr + 1;
            else
                x = x + 100;
            end
        else
            v:setVisible(false);
        end
    end

    if self.loading then
        self:drawRect(0, 0, self:getWidth(), self:getHeight(), 0.8, 0.1, 0.1, 0.1);
        self:drawTextCentre(getText("IGUI_DbViewer_Loading"),  self:getWidth()/2,  self:getHeight()/2, 1,1,1,1,UIFont.Large);
    end
end

function DatabaseListTable:createChildren()
    ISPanel.createChildren(self);

    self.datas = ISScrollingListBox:new(10, HEADER_HGT, self.width - 20, self.height - 230);
    self.datas:initialise();
    self.datas:instantiate();
    self.datas.itemheight = FONT_HGT_SMALL + 2 * 2
    self.datas.selected = 0;
    self.datas.joypadParent = self;
    self.datas.font = UIFont.NewSmall;
    self.datas.doDrawItem = self.drawDatas;
    self.datas.drawBorder = true;
    self.datas.parent = self;
    self:addChild(self.datas);

    self.pagePanel = ISPanel:new(0, self.datas:getBottom(), 100, FONT_HGT_MEDIUM + 2 * 2)
    self.pagePanel:initialise()
    self.pagePanel:instantiate()
    self.pagePanel:noBackground()
    self:addChild(self.pagePanel)

    self.nbrPerPageLbl = ISLabel:new(0, 0, self.pagePanel.height, getText("IGUI_DbViewer_NbrPerPage"), 1, 1, 1, 1, UIFont.Small, true);
    self.nbrPerPageLbl:initialise();
    self.nbrPerPageLbl:instantiate();
    self.pagePanel:addChild(self.nbrPerPageLbl);

    local textWid = getTextManager():MeasureStringX(UIFont.Medium, "9999")
    self.nbrPerPages = ISTextEntryBox:new("500", self.nbrPerPageLbl:getRight() + 6, 0, textWid + 2 * 2, FONT_HGT_MEDIUM + 2 * 2);
    self.nbrPerPages.font = UIFont.Medium
    self.nbrPerPages:initialise();
    self.nbrPerPages:instantiate();
    self.nbrPerPages:setOnlyNumbers(true);
    self.nbrPerPages.onTextChange = DatabaseListTable.onNbrPerPageChange;
    self.nbrPerPages.target = self;
    self.nbrPerPages.tableName = self.tableName;
    self.pagePanel:addChild(self.nbrPerPages);

    self.pagesLbl = ISLabel:new(self.nbrPerPages:getRight() + 6, 0, self.pagePanel.height, getText("IGUI_DbViewer_Page"), 1, 1, 1, 1, UIFont.Small, true);
    self.pagesLbl:initialise();
    self.pagesLbl:instantiate();
    self.pagePanel:addChild(self.pagesLbl);

    self.prePage = ISButton:new(self.pagesLbl:getRight() + 6, 0, 15, self.pagePanel.height, "<", self, DatabaseListTable.onOptionPage);
    self.prePage.internal = "PREVIOUS";
    self.prePage:initialise();
    self.prePage:instantiate();
    self.prePage.borderColor = self.buttonBorderColor;
    self.pagePanel:addChild(self.prePage);

    self.pageLbl = ISLabel:new(self.prePage:getRight() + 6, 0, self.pagePanel.height, "1/1", 1, 1, 1, 1, UIFont.Small, true);
    self.pageLbl:initialise();
    self.pageLbl:instantiate();
    self.pagePanel:addChild(self.pageLbl);

    self.nextPage = ISButton:new(self.pageLbl:getRight() + 6, 0, 15, self.pagePanel.height, ">", self, DatabaseListTable.onOptionPage);
    self.nextPage.internal = "NEXT";
    self.nextPage:initialise();
    self.nextPage:instantiate();
    self.nextPage.borderColor = self.buttonBorderColor;
    self.pagePanel:addChild(self.nextPage);

    self.pagePanel:setWidth(self.nextPage:getRight())
    self.pagePanel:setX(self.width - self.pagePanel.width - 10)

    for _, type in pairs(self.columns) do
        local size = 100;
        local entryHgt = FONT_HGT_SMALL + 2 * 2

        if type["type"] == "TEXT" or type["type"] == "INTEGER" or type["type"] == "JSON" then
            self.entry = ISTextEntryBox:new("", 10,  self.datas.x + self.datas.height + 85, size, entryHgt);
            self.entry.font = UIFont.Medium
            self.entry:initialise();
            self.entry:instantiate();
            self.entry.columnName = type["name"];
            self.entry.type = type["type"];
            self.entry.tableName = self.tableName;
            if type["type"] == "INTEGER" then
                self.entry:setOnlyNumbers(true);
            end
            self.entry.onTextChange = DatabaseListTable.onFilterChange;
            self.entry.target = self;
            self:addChild(self.entry);
            table.insert(self.filters, self.entry);
        end

        if type["type"] == "BOOLEAN" then
            self.combo = ISComboBox:new(10,  self.datas.x + self.datas.height + 85, size, entryHgt, nil,nil);
            self.combo:initialise();
            self:addChild(self.combo);
            self.combo:addOption("");
            self.combo:addOption("true");
            self.combo:addOption("false");
            self.combo.type = type["type"];
            self.combo.columnName = type["name"];
            self.combo.onChange = DatabaseListTable.onFilterChange;
            self.combo.target = self;
            self.combo.tableName = self.tableName;
            self.combo.isComboBox = true;
            table.insert(self.filters, self.combo);
        end
    end
end

function DatabaseListTable.onFilterChange(entry, combo)
    local view = DatabaseListViewer.instance.panel:getView(entry.tableName)
    local filterTxt = "";
    local columnName = entry.columnName;

    if combo then
        if combo.selected == 2 then
            filterTxt = "true";
        elseif combo.selected == 3 then
            filterTxt = "false";
        end
        columnName = combo.columnName;
    else
        filterTxt = entry:getInternalText();
    end

    view.datas:clear();
    view.columnSize = {};
    view.filtered = string.trim(filterTxt) ~= "";
    local allPagesFilter = {};
    local newPage = ArrayList.new();
    view.pages = {};
    local size = 0;
    view.totalResult = 0;

    for _, v in ipairs(view.fullPages) do
        for key, valueqqq in pairs(v) do
            local data = {};
            data.datas = {};
            local add = true;

            local fields = {["key"] = key, ["value"] = valueqqq}

            for fieldName, fieldValue in pairs(fields) do
                local colName = fieldName;
                local value = fieldValue;
                if type(value) == "table" then
                    value = openutils.ConvertTableToJson(value)
                end

                if filterTxt and filterTxt ~= "" and (colName == columnName and not luautils.stringStarts(string.lower(value), string.lower(filterTxt))) then
                    add = false;
                end
                data.datas[colName] = value;

                if add then
                    local currentSize = view.columnSize[colName];
                    if not currentSize then currentSize = 0; end
                    if currentSize < getTextManager():MeasureStringX(UIFont.Large, data.datas[colName]) + 5 then
                        currentSize = getTextManager():MeasureStringX(UIFont.Large, data.datas[colName]) + 5;
                    end

                    if currentSize < getTextManager():MeasureStringX(UIFont.Large, colName) + 5 then
                        currentSize = getTextManager():MeasureStringX(UIFont.Large, colName) + 5;
                    end

                    if currentSize >= 200 then currentSize = 200; end
                    if colName == "value" then
                        if currentSize >= 700 then currentSize = 700; end
                    end

                    view.columnSize[colName] = currentSize;
                else
                    local currentSize = view.columnSize[colName];
                    if not currentSize then
                        view.columnSize[colName] = 100;
                    end
                end
            end

            if add then
                size = size + 1;
                view.totalResult = view.totalResult + 1;
                newPage:add(data);
                if #allPagesFilter == 0 then
                    view.datas:addItem(data.datas["username"], data);
                end
            end

            if size >= view.entriesPerPages then
                table.insert(allPagesFilter, newPage);
                newPage = ArrayList.new();
                size = 0;
            end
        end
    end

    if size > 0 then
        table.insert(allPagesFilter, newPage);
    end

    view.pages = allPagesFilter;
    view:doPagesButtons();
end

function DatabaseListTable:drawDatas(y, item, alt)
    local a = 0.9;

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.3, 0.7, 0.35, 0.15);
    end

    if alt then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.3, 0.6, 0.5, 0.5);
    end

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight, a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

    local x = 10;
    if self.parent and self.parent.columns then
        for name, type in pairs(self.parent.columns) do
            if type["name"] ~= "id" and type["name"] ~= "moderator" then
                self:drawText(item.item.datas[type["name"]], x, y + 2, 1, 1, 1, a, self.font);
                self:drawRect(x - 10, y - 1, 1, self.itemheight,1,self.borderColor.r, self.borderColor.g, self.borderColor.b);

                if self.parent.parent.activeView and self.parent.parent.activeView.columnSize[type["name"]] then
                    x = x + self.parent.parent.activeView.columnSize[type["name"]];
                else
                    x = x + 100;
                end
            end
        end
    end

    return y + self.itemheight;
end

function DatabaseListTable.onNbrPerPageChange(entry)
    local view = DatabaseListViewer.instance.panel:getView(entry.tableName);
    view.entriesPerPages = tonumber(entry:getInternalText());
    if view.entriesPerPages == nil then view.entriesPerPages = 1; end
    if #view.filters > 0 then
        view.onFilterChange(view.filters[1]);
    end
end

function DatabaseListTable:clearFilters()
    for _,v in ipairs(self.filters) do
        if v.type =="BOOLEAN" then
            v.selected = 0;
        elseif v.type == "INTEGER" or v.type == "TEXT" or v.type == "JSON" then
            v:setText("");
        end
    end
end

function DatabaseListTable:clear()
    self.totalResult = 0;
    self.datas:clear();
    self.columnSize = {};
    self.pages = {};
    self.fullPages = {};
    self.loading = true;
end

function DatabaseListTable:doPagesButtons()
    local pagesNbr = #self.pages;

    if pagesNbr == 0 then
        pagesNbr = 1;
        self.nextPage.enable = false;
        self.prePage.enable = false;
    end

    if pagesNbr > 1 then
        self.nextPage.enable = true;
        self.prePage.enable = true;
    end

    self.currentPage = 1;
    self.pageLbl.name = "1/" .. pagesNbr;
end

function DatabaseListTable:onOptionPage(button, x, y)
    if button.internal == "NEXT" then
        self.currentPage = self.currentPage + 1;

        if self.currentPage > #self.pages then
            self.currentPage = #self.pages;
        end

        self.pageLbl.name = self.currentPage .. "/" .. #self.pages;
        self.datas:clear();
        local datas = DatabaseListTable:convertTableToKeyValueObject(self.pages[self.currentPage])
        self:computeResult(datas, self);
    end

    if button.internal == "PREVIOUS" then
        self.currentPage = self.currentPage - 1;

        if self.currentPage < 1 then
            self.currentPage = 1;
        end

        self.pageLbl.name = self.currentPage .. "/" .. #self.pages;
        self.datas:clear();
        local datas = DatabaseListTable:convertTableToKeyValueObject(self.pages[self.currentPage])
        self:computeResult(datas, self);
    end
end

function DatabaseListTable:convertTableToKeyValueObject(tbl)
    local datas = {}

    for i=0, tbl:size()-1 do
        local dbResult = tbl:get(i).datas;
        if dbResult then
            local key = dbResult["key"]
            local value = dbResult["value"]

            if key and value then
                datas[key] = openutils.ConvertJsonToTable(value)
            end
        end
    end

    return datas
end

function DatabaseListTable:computeResult(datas)
    self.columnSize = {};

    for key, value in pairs(datas) do
        local data = {};
        data.datas = {};

        local colName = "key";
        data.datas[colName] = key;
        local currentSize = self.columnSize[colName];
        if not currentSize then currentSize = 0; end

        if currentSize < getTextManager():MeasureStringX(UIFont.Large, data.datas[colName]) + 5 then
            currentSize = getTextManager():MeasureStringX(UIFont.Large, data.datas[colName]) + 5;
        end

        if currentSize < getTextManager():MeasureStringX(UIFont.Large, colName) + 5 then
            currentSize = getTextManager():MeasureStringX(UIFont.Large, colName) + 5;
        end

        if currentSize >= 200 then currentSize = 200; end
        self.columnSize[colName] = currentSize;

        colName = "value";
        data.datas[colName] = openutils.ConvertTableToJson(value);
        currentSize = self.columnSize[colName];
        if not currentSize then currentSize = 0; end

        if currentSize < getTextManager():MeasureStringX(UIFont.Large, data.datas[colName]) + 5 then
            currentSize = getTextManager():MeasureStringX(UIFont.Large, data.datas[colName]) + 5;
        end

        if currentSize < getTextManager():MeasureStringX(UIFont.Large, colName) + 5 then
            currentSize = getTextManager():MeasureStringX(UIFont.Large, colName) + 5;
        end

        if currentSize >= 700 then currentSize = 700; end
        self.columnSize[colName] = currentSize;

        self.datas:addItem(data.datas["username"], data);
    end
end

-- getTableResult converts data to DatabaseListTable format and fills table.
function DatabaseListTable.getTableResult(datas, rowId, tableName)
    local view = DatabaseListViewer.instance.panel:getView(tableName)
    view.loading = false;

    local len = openutils.ObjectLen(datas)

    if len > 0 then
        if rowId == 0 then
            view.totalResult = 0;
            view.datas:clear();
            view.columnSize = {};
            view.pages = {};
        end

        view.totalResult = view.totalResult + len;
        table.insert(view.pages, datas);
        table.insert(view.fullPages, datas);
        view.pageLbl.name = "1/" .. #view.pages;

        if rowId == 0 then
            view:computeResult(datas);
        end

        view:doPagesButtons();
    end
end

function DatabaseListTable.OnServerCommand(module, command, args)
    if not isClient() then return end

    if module ~= "ServerTweaker" then
        return
    end

    if not args or type(args) ~= "table" then
        return
    end

    if not args.dbname or type(args.dbname) ~= "string" or args.dbname == "" then
        return
    end

    if not LuaDatabaseClient.buckets[args.dbname] then
        return
    end

    if command == "DatabaseListTable" then
        logger.Debug("OpenStorage: DatabaseListTable OnServerCommand validated", {request_id = args.request_id, dbname = args.dbname, command = command, response_id = args.response_id})

        DatabaseListTable.getTableResult(args.data, 0, args.dbname)
    end
end

Events.OnServerCommand.Add(DatabaseListTable.OnServerCommand);
