B4J=true
Group=Controllers
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
' Api Controller
' Version 1.06
' For creating Controller such as ProductsController
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
End Sub

Public Sub Initialize (req As ServletRequest, resp As ServletResponse)
	Request = req
	Response = resp
	HRM.Initialize
	DB.Initialize(Main.DBOpen, Main.DBEngine)
End Sub

Private Sub ReturnApiResponse 'ignore
	HRM.SimpleResponse = Main.SimpleResponse
	WebApiUtils.ReturnHttpResponse(HRM, Response)
End Sub

Private Sub ReturnBadRequest
	WebApiUtils.ReturnBadRequest(Response)
End Sub

Private Sub ReturnMethodNotAllow
	WebApiUtils.ReturnMethodNotAllow(Response)
End Sub

Private Sub ReturnErrorUnprocessableEntity
	WebApiUtils.ReturnErrorUnprocessableEntity(Response)
End Sub

' Api Router
Public Sub RouteApi
	Method = Request.Method.ToUpperCase
	Elements = WebApiUtils.GetUriElements(Request.RequestURI)
	ApiVersionIndex = Main.Element.ApiVersionIndex
	ControllerIndex = Main.Element.ApiControllerIndex
	Version = Elements(ApiVersionIndex)
	ElementLastIndex = Elements.Length - 1
	If ElementLastIndex > ControllerIndex Then
		FirstIndex = ControllerIndex + 1
		FirstElement = Elements(FirstIndex)
	End If

	Select Method
		Case "GET"
			' Snippet: Code_WebApiUtils_03 GET Route
			RouteGet
		Case "POST"
			' Snippet: Code_WebApiUtils_04 POST Route
			'RoutePost
		Case "PUT"
			' Snippet: Code_WebApiUtils_05 PUT Route
			'RoutePut
		Case "DELETE"
			' Snippet: Code_WebApiUtils_06 DELETE Route
			'RouteDelete
		Case Else
			Log("Unsupported method: " & Method)
			ReturnMethodNotAllow
	End Select
End Sub

' Web Router
Public Sub RouteWeb
	Method = Request.Method.ToUpperCase
	Elements = WebApiUtils.GetUriElements(Request.RequestURI)
	ElementLastIndex = Elements.Length - 1
	ControllerIndex = Main.Element.WebControllerIndex
	If ElementLastIndex > ControllerIndex Then
		FirstIndex = ControllerIndex + 1
		FirstElement = Elements(FirstIndex)
	End If
	
	Select Method
		Case "GET"
			Select ElementLastIndex
				Case ControllerIndex
					' Snippet: Code_WebApiUtils_07 Show Web Page
					'ShowPage
					Return
			End Select
		Case Else
			Log("Unsupported method: " & Method)
			WebApiUtils.ReturnMethodNotAllow(Response)
	End Select
End Sub

' Snippet: Code_WebApiUtils_03 GET Route
Private Sub RouteGet
	Select Version
		Case "v2"
			Select ElementLastIndex
				Case ControllerIndex
					' Snippet: Code_MiniORMUtils_01 Get Resources as List
					'GetPlural
					Return
				Case FirstIndex
					If IsNumber(FirstElement) = False Then
						ReturnErrorUnprocessableEntity
						Return
					End If
					' Snippet: Code_MiniORMUtils_02 Get Resource as Map by Id
					'GetSingular(FirstElement)
					Return
			End Select
	End Select
	ReturnBadRequest
End Sub