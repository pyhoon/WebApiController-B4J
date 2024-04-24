B4J=true
Group=Controllers
ModulesStructureVersion=1
Type=Class
Version=9.8
@EndOfDesignText@
' Find Controller
' Version 1.05
' For creating a Find Controller (with Categories and Products controllers )
Sub Class_Globals
	Private Request As ServletRequest
	Private Response As ServletResponse
	Private HRM As HttpResponseMessage
	Private DB As MiniORM
	Private Method As String
	Private Version As String
	Private Elements() As String
	Private ApiVersionIndex As Int
	Private ControllerIndex As Int
	Private ElementLastIndex As Int
	Private FirstIndex As Int
	Private FirstElement As String
	Private SecondIndex As Int
	Private SecondElement As String
	Private ThirdIndex As Int
	Private ThirdElement As String
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

Private Sub ReturnBadRequest
	WebApiUtils.ReturnBadRequest(Response)
End Sub

Private Sub ReturnMethodNotAllow
	WebApiUtils.ReturnMethodNotAllow(Response)
End Sub

Private Sub ReturnInvalidKeywordValue
	HRM.ResponseCode = 400
	HRM.ResponseError = "Invalid keyword value"
End Sub

Private Sub ReturnErrorUnprocessableEntity
	WebApiUtils.ReturnErrorUnprocessableEntity(Response)
End Sub

' Api Router
Public Sub RouteApi
	Method = Request.Method.ToUpperCase
	Elements = WebApiUtils.GetUriElements(Request.RequestURI)
	ElementLastIndex = Elements.Length - 1
	ApiVersionIndex = Main.Element.ApiVersionIndex
	Version = Elements(ApiVersionIndex)
	ControllerIndex = Main.Element.ApiControllerIndex
	If ElementLastIndex > ControllerIndex Then
		FirstIndex = ControllerIndex + 1
		FirstElement = Elements(FirstIndex)
	End If
	If ElementLastIndex > ControllerIndex + 1 Then
		SecondIndex = ControllerIndex + 2
		SecondElement = Elements(SecondIndex)
	End If
	If ElementLastIndex > ControllerIndex + 2 Then
		ThirdIndex = ControllerIndex + 3
		ThirdElement = Elements(ThirdIndex)
	End If

	Select Method
		Case "GET"
			RouteGet
		Case Else
			Log("Unsupported method: " & Method)
			ReturnMethodNotAllow
	End Select
End Sub

' Router for GET request
Private Sub RouteGet
	Select Version
		Case "v2"
			Select ElementLastIndex
				Case ThirdIndex
					Select FirstElement
						Case "category"
							GetFindCategory(SecondElement, ThirdElement)
							Return
						Case "product"
							GetFindProduct(SecondElement, ThirdElement)
							Return
					End Select					
			End Select
	End Select
	ReturnBadRequest
End Sub

Private Sub GetFindCategory (keyword As String, value As String)
	' #Version = v2
	' #Desc = Find Category by name
	' #Elements = ["category", ":keyword", ":value"]

	Select keyword
		Case "category_name", "name"
			QueryCategoryByKeyword(Array("category_name = ?"), Array(value))
		Case Else
			ReturnInvalidKeywordValue
	End Select
	DB.Close
	ReturnApiResponse
End Sub

Private Sub GetFindProduct (keyword As String, value As String)
	' #Version = v2
	' #Desc = Find Product by id, cid, code or name
	' #Elements = ["product", ":keyword", ":value"]

	Select keyword
		Case "id"
			If IsNumber(value) Then
				QueryProductByKeyword(Array("p.id = ?"), Array(value))
			Else
				ReturnErrorUnprocessableEntity			
			End If
		Case "category_id", "cid", "catid"
			If IsNumber(value) Then
				QueryProductByKeyword(Array("c.id = ?"), Array(value))
			Else
				ReturnErrorUnprocessableEntity			
			End If
		Case "product_code", "code"		
			QueryProductByKeyword(Array("p.product_code = ?"), Array(value))
		Case "category_name", "category"					
			QueryProductByKeyword(Array("c.category_name = ?"), Array(value))
		Case "product_name", "name"			
			QueryProductByKeyword(Array("p.product_name LIKE ?"), Array("%" & value & "%"))
		Case Else
			ReturnInvalidKeywordValue
	End Select
	DB.Close
	ReturnApiResponse
End Sub

Private Sub QueryCategoryByKeyword (Condition As List, Value As List)
	DB.Table = "tbl_category"
	DB.setWhereValue(Condition, Value)
	DB.Query
	HRM.ResponseCode = 200
	HRM.ResponseData = DB.Results
End Sub

Private Sub QueryProductByKeyword (Condition As List, Value As List)
	DB.Table = "tbl_products p"
	DB.Select = Array("p.*", "c.category_name")
	DB.Join = DB.CreateORMJoin("tbl_category c", "p.category_id = c.id", "")
	DB.setWhereValue(Condition, Value)
	DB.Query
	HRM.ResponseCode = 200
	HRM.ResponseData = DB.Results
End Sub