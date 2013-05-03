<?php
$option = $_REQUEST['option'];

if(!$option){
	$option = "sendForm";
}

switch($option){
		case "sendForm":
			sendForm($uID);
		break;
		case "view":
			$file = $_REQUEST['file'];
			view($file);
		break;
		case "email":
			$name = $_REQUEST['name'];
			$email = $_REQUEST['email'];
			$file = $_REQUEST['file'];
			email($name, $email, $file);
		break;		
}

function email($name, $email, $file){
	$to = $email;

	$subject = "$name recorded a video for you...";
	
	$headers = "From: support@whitelbl.com \r\n";
	$headers .= "Reply-To: support@whitelbl.com \r\n";
	$headers .= "MIME-Version: 1.0\r\n";
	$headers .= "Content-Type: text/html; charset=ISO-8859-1\r\n";
	
	$url = "http://apps.whitelbl.com/avrecorder/deploy/?option=view&file=$file";
	
	$message = "You have a video waiting for you at $url";
	
	mail($to, $subject, $message, $headers);
}

function view($file){
	?>
    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>AV Recorder Demo</title>
</head>
<body  leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,0,0" width="100%" height="100%" id="main" align="middle">
	<param name="allowScriptAccess" value="sameDomain" />
	<param name="allowFullScreen" value="true" />
	<param name="movie" value="main.swf?applicationView=player&file=<?php echo $file; ?>&autoStart=true" />
	<param name="menu" value="false" />
	<param name="quality" value="best" />
	<param name="scale" value="noscale" />
	<param name="salign" value="lt" />
	<param name="wmode" value="opaque" />
	<param name="bgcolor" value="#003333" />	
	<embed src="main.swf?applicationView=player&file=<?php echo $file; ?>&autoStart=true" menu="false" quality="best" scale="noscale" salign="lt" wmode="opaque" bgcolor="#003333" width="100%" height="100%" name="main" align="middle" allowScriptAccess="sameDomain" allowFullScreen="true" type="application/x-shockwave-flash" pluginspage="http://www.adobe.com/go/getflashplayer" />
	</object>
</body></html>
    <?php
}


function sendForm($uID){
	$file = guid();
	?>
	<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
    <head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
    <title>AV Recorder Demo</title>
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js" type="text/javascript"></script>
    
    </head>
    <body  leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
    <div id="copypaste" class="avMailForm" style="width: 400px; float:left; clear:left; padding: 20px;">
	    <h1>AV Recorder Demo</h1>
        <p>Simply copy the text below into your website!</p>
		<script type="text/javascript" language="javascript">
		
		function highlight(field) {
			field.focus();
			field.select();
		}
		
		function sendMail() {
			var name = document.getElementById('name').value;
			var email = document.getElementById('email').value;
			if(name != ""){
				
				document.getElementById('namelabel').innerHTML = "Your Name:";
				if(email != ""){
				
							
				document.getElementById('emaillabel').innerHTML = "Friends Email:";
				// Run webservice baby!
				document.getElementById('name').value = "";
				document.getElementById('email').value = "";
				var urlis = "?option=email&email=" + email + "&name=" + name + "&file=<?php echo $file; ?>";
				
				$.ajax({
				  url: urlis,
				  success: function(){
					alert("Email Sent");
				  }
				});
				
							
				return false;
				} else {
				document.getElementById('emaillabel').innerHTML = "Friends Email: -Required";
				}
			} else {
			document.getElementById('namelabel').innerHTML = "You Name: -Required";
				if(email == ""){
				document.getElementById('emaillabel').innerHTML = "Friends Email: -Required";
				}
			}
			return false;
		}
		
		function succesAjax (t)
		{	
			Effect.Fade('submitting');
			
			// Show the form again!
			//alert("here");
				
		}
		
		function failAjax (t)
		{
			alert('Error ' + t.status + ' -- ' + t.statusText);  
		}
		
		
		</script>
		<textarea name="copynpastetext" onclick="highlight(this);" style="width:400; height:100px" cols="" rows="">&lt;object classid=&quot;clsid:d27cdb6e-ae6d-11cf-96b8-444553540000&quot; codebase=&quot;http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,0,0&quot; width=&quot;100%&quot; height=&quot;100%&quot; id=&quot;main&quot; align=&quot;middle&quot;&gt;
&lt;param name=&quot;allowScriptAccess&quot; value=&quot;sameDomain&quot; /&gt;
&lt;param name=&quot;allowFullScreen&quot; value=&quot;true&quot; /&gt;
&lt;param name=&quot;movie&quot; value=&quot;http://apps.whitelbl.com/avrecorder/deploy/main.swf?applicationView=player&amp;file=<?php echo $file; ?>&amp;autoStart=true&quot; /&gt;
&lt;param name=&quot;menu&quot; value=&quot;false&quot; /&gt;
&lt;param name=&quot;quality&quot; value=&quot;best&quot; /&gt;
&lt;param name=&quot;scale&quot; value=&quot;noscale&quot; /&gt;
&lt;param name=&quot;salign&quot; value=&quot;lt&quot; /&gt;
&lt;param name=&quot;wmode&quot; value=&quot;opaque&quot; /&gt;
&lt;param name=&quot;bgcolor&quot; value=&quot;#003333&quot; /&gt; 
&lt;embed src=&quot;http://apps.whitelbl.com/avrecorder/deploy/main.swf?applicationView=player&amp;file=<?php echo $file; ?>&amp;autoStart=true&quot; menu=&quot;false&quot; quality=&quot;best&quot; scale=&quot;noscale&quot; salign=&quot;lt&quot; wmode=&quot;opaque&quot; bgcolor=&quot;#003333&quot; width=&quot;100%&quot; height=&quot;100%&quot; name=&quot;main&quot; align=&quot;middle&quot; allowScriptAccess=&quot;sameDomain&quot; allowFullScreen=&quot;true&quot; type=&quot;application/x-shockwave-flash&quot; pluginspage=&quot;http://www.adobe.com/go/getflashplayer&quot; /&gt;
&lt;/object&gt;</textarea>
	
	
	<form id="myform" name="myform" action="avrecorderdemo.php" method="POST" onSubmit="return sendMail();">
	<div id="namelabel">You Name:</div>
	<input id="name" name="name" style="width: 400px;" type="text" />
	<div id="emaillabel">Friends Email:</div>
	<input id="email" name="email" style="width: 400px;" type="text"/>
	<div align="right" class="submitButton" style="margin-top: 10px;"><input id="sendBtn" name="sendBtn" type="submit" value="Send Email" /></div>
	</form>
	</div>
	
	
	<div style="width: 500px; height:400px; float:left; padding: 20px;">
    <script type="text/javascript" language="javascript">
		function saveVideo(inObject){
			alert("The user " + inObject.user + " has submitted a request to save the video " +  inObject.file);
			
			/* 
			   Save Video Coding
				
			   You will need to add your coding here to save a record to a db table with a reference to the
			   user and video.  You can use ajax xmlequest to accomplish this.
			   
			   Todo: Make an example call to a default php page that simply returns a message of video
			   has been saved. This will give clients an example out of the box.
			   
			   
			*/
		}
	</script>
	<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,0,0" width="100%" height="100%" id="main" align="middle">
	<param name="allowScriptAccess" value="sameDomain" />
	<param name="allowFullScreen" value="true" />
	<param name="movie" value="main.swf?applicationView=recorder&file=<?php echo $file; ?>" />
	<param name="menu" value="false" />
	<param name="quality" value="best" />
	<param name="scale" value="noscale" />
	<param name="salign" value="lt" />
	<param name="wmode" value="opaque" />
	<param name="bgcolor" value="#003333" />	
	<embed src="main.swf?applicationView=recorder&file=<?php echo $file; ?>" menu="false" quality="best" scale="noscale" salign="lt" wmode="opaque" bgcolor="#003333" width="100%" height="100%" name="main" align="middle" allowScriptAccess="sameDomain" allowFullScreen="true" type="application/x-shockwave-flash" pluginspage="http://www.adobe.com/go/getflashplayer" />
	</object>
	</div>
</body></html>
<?php
} 


function guid()
{
    if (function_exists('com_create_guid') === true)
    {
        return trim(com_create_guid(), '{}');
    }

    return sprintf('%04X%04X-%04X-%04X-%04X-%04X%04X%04X', mt_rand(0, 65535), mt_rand(0, 65535), mt_rand(0, 65535), mt_rand(16384, 20479), mt_rand(32768, 49151), mt_rand(0, 65535), mt_rand(0, 65535), mt_rand(0, 65535));
}
?>