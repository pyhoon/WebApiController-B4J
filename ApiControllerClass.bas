B4J=true
Group=Controllers
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
' Api Controller
' Version 1.07
Sub Class_Globals
	Private Request As ServletRequest
	Private Response As ServletResponse
	Private HRM As HttpResponseMessage
	Private DB As MiniORM
	Private Method As String
	Private Version As String
	Private RequestURI As String 'ignore
	Private Elements() As String
	Private ElementLastIndex As Int
	Private ApiVersionIndex As Int
	Private ControllerIndex As Int
	Private ControllerElement As String 'ignore
	Private FirstIndex As Int
	Private FirstElement As String
	Private SecondIndex As Int 'ignore
	Private SecondElement As String 'ignore
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

Public Sub RouteApi
	Method = Request.Method.ToUpperCase
	RequestURI = Request.RequestURI
	Elements = WebApiUtils.GetUriElements(RequestURI)
	ApiVersionIndex = Main.Element.ApiVersionIndex
	ControllerIndex = Main.Element.ApiControllerIndex
	ControllerElement = Elements(ControllerIndex)
	Version = Elements(ApiVersionIndex)
	ElementLastIndex = Elements.Length - 1
	If ElementLastIndex > ControllerIndex Then
		FirstIndex = ControllerIndex + 1
		FirstElement = Elements(FirstIndex)
	End If

	Select Method
		Case "GET"
			RouteGet
		Case "POST"
			'RoutePost
		Case "PUT"
			'RoutePut
		Case "DELETE"
			'RouteDelete
		Case Else
			Log("Unsupported method: " & Method)
			ReturnMethodNotAllow
	End Select
End Sub

Public Sub RouteWeb
	Method = Request.Method.ToUpperCase
	RequestURI = Request.RequestURI
	Elements = WebApiUtils.GetUriElements(RequestURI)
	ElementLastIndex = Elements.Length - 1
	ControllerIndex = Main.Element.WebControllerIndex
	ControllerElement = Elements(ControllerIndex)
	If ElementLastIndex > ControllerIndex Then
		FirstIndex = ControllerIndex + 1
		FirstElement = Elements(FirstIndex)
	End If
	
	Select Method
		Case "GET"
			Select ElementLastIndex
				Case ControllerIndex
					'ShowPage
					Return
			End Select
		Case Else
			Log("Unsupported method: " & Method)
			ReturnMethodNotAllow
	End Select
End Sub

' GET
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