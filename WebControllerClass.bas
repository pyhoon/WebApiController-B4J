﻿B4J=true
Group=Controllers
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
' Web Controller
' Version 1.05
' For creating Controller such as IndexController (that does not return Api)
Sub Class_Globals
	Private Request As ServletRequest
	Private Response As ServletResponse
	Private HRM As HttpResponseMessage
	Private DB As MiniORM
End Sub

Public Sub Initialize (req As ServletRequest, resp As ServletResponse)
	Request = req
	Response = resp
	HRM.Initialize
	HRM.SimpleResponse = Main.SimpleResponse
	DB.Initialize(Main.DBOpen, Main.DBEngine)
End Sub

Private Sub ReturnApiResponse
	WebApiUtils.ReturnHttpResponse(HRM, Response)
End Sub

Public Sub Show
	Dim strMain As String = WebApiUtils.ReadTextFile("main.html")
	Dim strView As String = WebApiUtils.ReadTextFile("index.html")
	Dim strJSFile As String
	Dim strScripts As String
	
	strMain = WebApiUtils.BuildDocView(strMain, strView)
	strMain = WebApiUtils.BuildHtml(strMain, Main.Config)
	If Main.SimpleResponse.Enable Then
		If Main.SimpleResponse.Format = "Map" Then
			strJSFile = "webapi.search.simple.map.js"
		Else
			strJSFile = "webapi.search.simple.js"
		End If		
	Else
		strJSFile = "webapi.search.js"
	End If
	strScripts = $"<script src="${Main.Config.Get("ROOT_URL")}/assets/js/${strJSFile}"></script>"$
	strMain = WebApiUtils.BuildScript(strMain, strScripts)
	WebApiUtils.ReturnHTML(strMain, Response)
End Sub

Public Sub GetSearch
	DB.Table = "tbl_products p"
	DB.Select = Array("p.*", "c.category_name")
	DB.Join = DB.CreateORMJoin("tbl_category c", "p.category_id = c.id", "")
	DB.OrderBy = CreateMap("p.id": "")
	DB.Query
	HRM.ResponseCode = 200
	HRM.ResponseData = DB.Results
	DB.Close
	ReturnApiResponse
End Sub

Public Sub PostSearch
	Dim SearchForText As String
	Dim Data As Map = WebApiUtils.RequestData(Request)
	If Data.IsInitialized Then
		SearchForText = Data.Get("keywords")
	End If

	DB.Table = "tbl_products p"
	DB.Select = Array("p.*", "c.category_name")
	DB.Join = DB.CreateORMJoin("tbl_category c", "p.category_id = c.id", "")
	If SearchForText <> "" Then
		DB.Where = Array("product_code LIKE ? Or product_name LIKE ? Or category_name LIKE ?")
		DB.Parameters = Array("%" & SearchForText & "%", "%" & SearchForText & "%", "%" & SearchForText & "%")
	End If
	DB.OrderBy = CreateMap("p.id": "")
	DB.Query
	HRM.ResponseCode = 200
	HRM.ResponseData = DB.Results
	DB.Close
	ReturnApiResponse
End Sub