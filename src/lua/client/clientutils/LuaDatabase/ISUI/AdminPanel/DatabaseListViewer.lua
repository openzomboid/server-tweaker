--
-- Copyright (c) 2024 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

require "ISUI/ISPanel"

DatabaseListViewer = ISPanel:derive("DatabaseListViewer");
DatabaseListViewer.bottomInfoHeight = 40;

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

function DatabaseListViewer:new(x, y, width, height)
    x = (getCore():getScreenWidth() / 2) - (width / 2);
    y = (getCore():getScreenHeight() / 2) - (height / 2);

    local o = ISPanel:new(x, y, width, height);
    setmetatable(o, self);
    self.__index = self;
    o.backgroundColor = {r=0, g=0, b=0, a=0.8};
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5};
    o.moveWithMouse = true;
    o.canModify = getAccessLevel() == "admin";
    o.schema = DatabaseListViewer.getDBSchema();
    DatabaseListViewer.instance = o;

    return o;
end

function DatabaseListViewer:initialise()
    ISPanel.initialise(self);
end

function DatabaseListViewer:render()
    ISPanel.render(self);

    local z = 10;
    self:drawText(getText("IGUI_DbViewer_DbViewer"), self.width/2 - (getTextManager():MeasureStringX(UIFont.Medium, getText("IGUI_DbViewer_DbViewer")) / 2), z, 1, 1, 1, 1, UIFont.Medium);

    if self.activeView then
        if self.activeView.loading then
            self.refreshBtn.enable = false;
        else
            self.refreshBtn.enable = true;
        end
    end

    self:refreshButtons();
end

function DatabaseListViewer:onActivateView()
    LuaDatabaseClient.buckets[self.panel.activeView.view.tableName].GetFromServer("DatabaseListTable")
    self.activeView = self.panel.activeView.view;
    self.activeView:clear();
end

function DatabaseListViewer:refreshButtons()
    if self.activeView then
        if self.canModify then
            self.delete.enable = self.activeView.datas.selected > 0;
            self.modify.enable = self.activeView.datas.selected > 0;
            self.add.enable = self.activeView.datas.selected > 0;
        end
    end
end

function DatabaseListViewer:createChildren()
    ISPanel.createChildren(self);

    local btnWid = 100
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local padBottom = 10

    self.panel = ISTabPanel:new(1, 50, self.width - 2, self.height - 50 - 1);
    self.panel:initialise();
    self.panel.borderColor = { r = 0, g = 0, b = 0, a = 0};
    self.panel.onActivateView = DatabaseListViewer.onActivateView;
    self.panel.target = self;
    self:addChild(self.panel);

    self.close = ISButton:new(self:getWidth() - 100 - 10, self:getHeight() - btnHgt - padBottom, btnWid, btnHgt, getText("IGUI_CraftUI_Close"), self, DatabaseListViewer.onOptionMouseDown);
    self.close.internal = "CLOSE";
    self.close:initialise();
    self.close:instantiate();
    self.close.borderColor = self.buttonBorderColor;
    self:addChild(self.close);

    self.refreshBtn = ISButton:new(self:getWidth() - 200 - 15, self:getHeight() - btnHgt - padBottom, btnWid, btnHgt, getText("IGUI_DbViewer_Refresh"), self, DatabaseListViewer.onOptionMouseDown);
    self.refreshBtn.internal = "REFRESH";
    self.refreshBtn:initialise();
    self.refreshBtn:instantiate();
    self.refreshBtn.borderColor = self.buttonBorderColor;
    self:addChild(self.refreshBtn);

    self.modify = ISButton:new(10, self:getHeight() - btnHgt - padBottom, btnWid, btnHgt, getText("IGUI_DbViewer_Modify"), self, DatabaseListViewer.onOptionMouseDown);
    self.modify.internal = "MODIFY";
    self.modify:initialise();
    self.modify:instantiate();
    self.modify.enable = false;
    self.modify.borderColor = self.buttonBorderColor;
    self:addChild(self.modify);

    self.delete = ISButton:new(15 + btnWid, self:getHeight() - btnHgt - padBottom, btnWid, btnHgt, getText("IGUI_DbViewer_Delete"), self, DatabaseListViewer.onOptionMouseDown);
    self.delete.internal = "DELETE";
    self.delete:initialise();
    self.delete:instantiate();
    self.delete.borderColor = self.buttonBorderColor;
    self.delete.enable = false;
    self:addChild(self.delete);

    self.add = ISButton:new(20 + btnWid*2, self:getHeight() - btnHgt - padBottom, btnWid, btnHgt, getText("IGUI_DbViewer_Add"), self, DatabaseListViewer.onOptionMouseDown);
    self.add.internal = "ADD";
    self.add:initialise();
    self.add:instantiate();
    self.add.borderColor = self.buttonBorderColor;
    self.add.enable = false;
    self:addChild(self.add);
end

function DatabaseListViewer:onOptionMouseDown(button, x, y)
    if button.internal == "CLOSE" then
        self:closeSelf()
    end

    if button.internal == "MODIFY" then
        local modal = DatabaseModifyRow:new(0, 0, 1000, 200, self.activeView, false);
        modal:initialise();
        modal:addToUIManager();
    end

    if button.internal == "ADD" then
        local modal = DatabaseModifyRow:new(0, 0, 1000, 200, self.activeView, true);
        modal:initialise();
        modal:addToUIManager();
    end

    if button.internal == "REFRESH" then
        self.activeView:clear();
        self.activeView:clearFilters();
        --getTableResult(self.activeView.tableName, self.activeView.entriesPerPages);
        LuaDatabaseClient.buckets[self.activeView.tableName].GetFromServer("DatabaseListTable")
    end

    if button.internal == "DELETE" then
        local modal = ISModalDialog:new(0,0, 250, 150, getText("IGUI_DbViewer_DeleteConfirm"), true, nil, DatabaseListViewer.onRemove, nil, self.activeView);
        modal:initialise()
        modal:addToUIManager()
        modal.moveWithMouse = true;
    end
end

function DatabaseListViewer:onRemove(button, view)
    if button.internal == "YES" then
        local key = view.datas.items[view.datas.selected].item.datas[view.columns[1].name]
        LuaDatabaseClient.buckets[view.tableName].Delete(key)
        view:clear();
        LuaDatabaseClient.buckets[view.tableName].GetFromServer("DatabaseListTable")
    end
end

function DatabaseListViewer:refresh()
    for i,l in pairs(self.schema) do
        local cat1 = DatabaseListTable:new(0, 0, self.panel.width, self.panel.height - self.panel.tabHeight, i);
        cat1.columns = l;
        cat1:initialise();
        self.panel:addView(i, cat1);
        cat1.parent = self;

        if not self.activeView then
            self.activeView = cat1;
            LuaDatabaseClient.buckets[i].GetFromServer("DatabaseListTable")
            cat1.loading = true;
        end
    end
end

function DatabaseListViewer.receiveDBSchema(schema)
    DatabaseListViewer.instance.schema = schema;
    DatabaseListViewer.instance:refresh();
end

function DatabaseListViewer:closeSelf()
    self:setVisible(false)
    self:removeFromUIManager()
end

function DatabaseListViewer.getDBSchema()
    local schema = {}

    local buckets = LuaDatabaseClient.buckets

    for dbname, bucket in pairs(buckets) do
        schema[dbname] = {}

        table.insert(schema[dbname], {["name"] = "key", ["type"] = "TEXT"})
        table.insert(schema[dbname], {["name"] = "value", ["type"] = "JSON"})
    end

    return schema
end
