<%@ Page Language="C#" %>


<%
    string usr = "admin";
    string pwd = "trms";
    
	bool postbackData = false;
	string method = "";
	string tag = "";
	string message = "";
    string logMessage = "";
    string rdaResponse = "";

	//get the querystring data
	if((Request.QueryString["tag"] != null) && (Request.QueryString["message"] != null))
	{
		if(Request.QueryString["tag"].ToString() != "")
			tag = Request.QueryString["tag"].ToString();
		if(Request.QueryString["message"].ToString() != "")
			message= Request.QueryString["message"].ToString();
		method = "get";
		postbackData = true;
	}
	//get the post data
	if((Request.Form["tag"] != null) && (Request.Form["message"] != null))
	{
		if(Request.Form["tag"] != null)
			tag = Request.Form["tag"].ToString();
		if(Request.Form["message"] != null)
			message = Request.Form["message"].ToString();
		method = "post";
		postbackData = true;
	}

    //postbackData = false;
	if(postbackData == true)
	{
	    //create RDA command
        string rda = "";
        string rda2 = "";
        if (message == "ALL CLEAR")
            rda = @"<?xml version=""1.0"" encoding=""utf-8"" ?><CarouselCommand xmlns=""http://www.trms.com/CarouselRemoteCommand""><ChangePageStatus><UserName>" + usr + "</UserName><Password>" + pwd + "</Password><SelectBulletinTags><Tag>" + tag + "</Tag></SelectBulletinTags><Status>off</Status></ChangePageStatus></CarouselCommand>";
        else
        {
            rda = "<?xml version=\"1.0\" encoding=\"utf-8\" ?><CarouselCommand xmlns=\"http://www.trms.com/CarouselRemoteCommand\"><UpdatePage><UserName>" + usr + "</UserName><Password>" + pwd + "</Password><SelectBulletinTags><Tag>" + tag + "</Tag></SelectBulletinTags><Block Name=\"message\" Value=\"" +  message + "\" /><ExclusiveAlertOn>true</ExclusiveAlertOn></UpdatePage></CarouselCommand>";
            rda2 += @"<?xml version=""1.0"" encoding=""utf-8"" ?><CarouselCommand xmlns=""http://www.trms.com/CarouselRemoteCommand""><ChangePageStatus><UserName>" + usr + "</UserName><Password>" + pwd + "</Password><SelectBulletinTags><Tag>" + tag + "</Tag></SelectBulletinTags><Status>on</Status></ChangePageStatus></CarouselCommand>";
        }
      
	    //send to the local Carousel via RDA
	    System.Net.Sockets.TcpClient socket = new System.Net.Sockets.TcpClient(); 
	    System.Net.Sockets.NetworkStream ns = null; 

	    socket = new System.Net.Sockets.TcpClient(); 
	    socket.Connect("localhost", 56906); 
	    ns = socket.GetStream(); 

	    byte[] cmd;
	    cmd = System.Text.Encoding.ASCII.GetBytes(rda.ToCharArray()); 
	    ns.Write(cmd, 0, cmd.Length);

	    // wait for data to be present for 10 seconds
        for (int i = 0; i < 100; i++)
        {
            if (ns.DataAvailable)
                break;
            System.Threading.Thread.Sleep(100); 
        }
        
	    byte[] RDAResponse = new byte[socket.ReceiveBufferSize]; 
		    string XML = String.Empty; 
		    while(ns.DataAvailable) { 
			    int length = ns.Read(RDAResponse, 0, socket.ReceiveBufferSize); 
			    if (length <= 0) 
				    break;
                     rdaResponse += Encoding.ASCII.GetString(RDAResponse, 0, length).Trim().Replace("\0", ""); //get rid of whitespace 
		    }

            cmd = System.Text.Encoding.ASCII.GetBytes(rda2.ToCharArray());
            ns.Write(cmd, 0, cmd.Length); 
        
	    ns.Close(); 
	    socket.Close(); 
	}
    

    if (postbackData == true)
        logMessage = DateTime.Now.ToString() + ": " + method + ": tag: " + tag + ", message: " + message + ": " + rdaResponse;
    else
        logMessage = DateTime.Now.ToString() + ": NO DATA POSTED";
        
	System.IO.StreamWriter sw = new System.IO.StreamWriter(Server.MapPath(".") + "log.txt", true, Encoding.UTF8);
	sw.WriteLine(logMessage);
	sw.Close();
%>

<html><head><title>SingleWire Tens Integration</title></head><body>

HTTP GET: <a href="SingleWire.aspx?tag=alert1&message=Test">Tag=Alert1 Message=Test</a><br />
HTTP GET: <a href="SingleWire.aspx?tag=alert1&message=ALL CLEAR">Tag=Alert1 Message=ALL CLEAR</a>

<hr />

<form action="SingleWire.aspx" method="post">Tag: <input name="tag" type="text" /><br />Message: <input name="message" type="text" /><br /><input value="Post" type="submit" /></form>

<hr />
Use ALL CLEAR in the message field to deactive the bulletin
<hr />
<% Response.Write(logMessage); %>

</body></html>