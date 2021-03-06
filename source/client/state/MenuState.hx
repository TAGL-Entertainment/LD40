package client.state;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxSliceSprite;
import flixel.addons.plugin.screengrab.FlxScreenGrab;
import flixel.addons.ui.FlxUIState;
import flixel.addons.util.PNGEncoder;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxAxes;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import haxe.Http;
import haxe.remoting.HttpAsyncConnection;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;
#if !flash
import sys.io.File;
#end
import firetongue.FireTongue;
import client.assetspath.ImageAssetsPath;
import shared.Score;

//SHARING OPTIONS
//import extension.share.Share;
import extension.share.Share;

class MenuState extends FlxState
{
	private var _volumeSprite			: FlxSprite;
	private var _backgroundSprite 		: FlxSprite;
	
	private var _tonguee					: FireTongue;

	override public function create():Void
	{
		bgColor = 0xFF000000;
		
		_tonguee = new FireTongue(Framework.OpenFL);
		_tonguee.init("fr-FR", onLoadedFireTongue);

		_backgroundSprite = new FlxSprite(0, 0);
		_backgroundSprite.loadGraphic(ImageAssetsPath.artworkS__png, true, 640, 480, true);
		_backgroundSprite.animation.add("YOLO", [0,1, 2,3, 4, 5, 6, 7, 8, 9,0,0], 9, true, false, false);

		add(_backgroundSprite);
		var title = new FlxText(0, 0, 0, "Filthy-rich and Fastuous", 40, true);
		title.color = 0xFF630000;
		title.screenCenter();
		title.y -= 150;
		title.borderStyle = FlxTextBorderStyle.OUTLINE_FAST;
		title.borderSize = 2;
		title.borderColor = FlxColor.WHITE;
		add(title);

		var credit = new FlxText(0, 0, 0, "Another stupid game by Lucas Tixier & Guillaume Ambrois", 12, true);
		credit.screenCenter(FlxAxes.X);
		credit.borderStyle = FlxTextBorderStyle.OUTLINE_FAST;
		credit.borderSize = 1;
		credit.borderColor = FlxColor.WHITE;
		credit.color = 0xFF630000;
		credit.y = title.y + 50;
		add(credit);

		var description = new FlxText(0, 0, FlxG.width - 50, "Buy (but don't sell!) ALL the items to delay your death by coins-crushing", 18, true);
		description.screenCenter(FlxAxes.X);
		description.color = FlxColor.WHITE;
		description.y = credit.y + 50;
		description.alignment = FlxTextAlign.CENTER;
		description.borderStyle = FlxTextBorderStyle.OUTLINE_FAST;
		description.borderSize = 2;
		description.borderColor = 0xFF630000;
		add(description);

		var startText = new FlxText(0, 0, 0, "", 24, true);

		#if mobile
		startText.text = "Touch anywhere to start";
		#end

		#if (web || desktop)
		startText.text = "Click or press SPACE to start";
		#end

		startText.color = 0xFF630000;
		startText.screenCenter();
		startText.y += 20;
		startText.borderStyle = FlxTextBorderStyle.OUTLINE_FAST;
		startText.borderSize = 2;
		startText.borderColor = FlxColor.WHITE;
		add(startText);

		FlxTween.tween(startText, {alpha: 0}, 0.7, {type: FlxTween.PINGPONG, ease: FlxEase.linear});

		#if (web || desktop)
		var soundText = new FlxText(0, 0, 0, "You can adjust the volume at any time by pressing the UP or DOWN keys", 12);
		soundText.screenCenter(FlxAxes.X);
		soundText.color = FlxColor.WHITE;
		soundText.y = FlxG.height - 150;
		soundText.borderStyle = FlxTextBorderStyle.OUTLINE_FAST;
		soundText.borderSize = 2;
		soundText.borderColor = 0xFF630000;
		add(soundText);
		#end

		var moreCreditAgain = new FlxText(0, 0, 0, "@LucasTixier - @Eponopono", 12, true);
		moreCreditAgain.screenCenter(FlxAxes.X);
		moreCreditAgain.color = 0xFF630000;
		moreCreditAgain.y = FlxG.height - 80;
		moreCreditAgain.borderStyle = FlxTextBorderStyle.OUTLINE_FAST;
		moreCreditAgain.borderSize = 2;
		moreCreditAgain.borderColor = FlxColor.WHITE;
		add(moreCreditAgain);

		var moreCredit = new FlxText(0, 0, 0, "Twitter :", 12, true);
		moreCredit.screenCenter(FlxAxes.X);
		moreCredit.color = 0xFF630000;
		moreCredit.y = moreCreditAgain.y - 20;
		moreCredit.borderStyle = FlxTextBorderStyle.OUTLINE_FAST;
		moreCredit.borderSize = 1;
		moreCredit.borderColor = FlxColor.WHITE;
		add(moreCredit);

		#if mobile
		FlxG.mouse.visible = false;
		#end

		FlxG.camera.fade(FlxColor.BLACK, .2, true);

		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		_backgroundSprite.animation.play("YOLO");
		
		#if (web || desktop)
		if (FlxG.mouse.justPressed || FlxG.keys.justPressed.SPACE)
		{
			FlxG.camera.fade(FlxColor.BLACK, .1, false, function()
			{
				FlxG.switchState(new PlayState());
			});
		}
		#end

		#if mobile
		if (FlxG.mouse.justPressed)
		{
			FlxG.camera.fade(FlxColor.BLACK, .1, false, function()
			{
				FlxG.switchState(new PlayState());
			});
		}
		#end
		
		#if debug
		#if (web || desktop)
		if (FlxG.keys.justPressed.S)
		{
			shareScore();
		}
		
		if (FlxG.keys.justPressed.F)
		{
			shareScoreF();
		}
		
		if (FlxG.keys.justPressed.L)
		{
			sendToLeaderboard();
		}
		if (FlxG.keys.justPressed.M)
		{
			getScores();
		}
		#end
		#end
	}
	
	public function sendToLeaderboard():Void
	{
		////var url:String = "http://httpbin.org/post";
		//var url:String = "localhost:8000";
		var nickname:String = "Eponopono";
		//
		var data:Score = {nickname: nickname, time: FlxG.random.float(10, 30), date: Date.now().getTime()};
		//var jsonData:String = haxe.Json.stringify(data);
		//
		//var req = new Http(url);
		//req.setPostData(jsonData);
		//
		//req.onData = function(data:String):Void
		//{
			//trace(data);
		//};
		//req.onError = function(msg:String):Void
		//{
			//trace(msg);
		//};
		//req.request(true);
		var url = "http://localhost:2000/server.n";
		var connection = HttpAsyncConnection.urlConnect(url);
		connection.setErrorHandler(function(err) { trace("Error : " + Std.string(err)); });
		connection.Server.sendScore.call([data], function(v) { trace(v);  getScores(); });
	}
	
	public function getScores()
	{
		var url = "http://localhost:2000/server.n";
		var connection = HttpAsyncConnection.urlConnect(url);
		connection.setErrorHandler(function(err) { trace("Error : " + Std.string(err)); });
		connection.Server.getScores.call([], function(v) { trace(v); });
	}
	
	private function shareScore()
	{
		#if !flash
		var screen = FlxScreenGrab.grab(new Rectangle(0, 0, 640, 480), true, true);
		
		FlxScreenGrab.defineHotKeys([FlxKey.K], true);
		FlxScreenGrab.grab(new Rectangle(0, 0, 640, 480), false);
		
		var png:ByteArray = PNGEncoder.encode(FlxScreenGrab.screenshot.bitmapData);
		
		var filename = 'F:/test' + FlxG.random.int(0,1000) + '_' +'.png';
		File.saveBytes(filename, png);
		
		
		Share.init(Share.TWITTER);
		Share.share("HELLO COME PLAY MY GAME : https://elryogrande.itch.io/filthy-rich",null,filename );
		#end
	}
	
	private function shareScoreF()
	{
		Share.init(Share.FACEBOOK);
		Share.share("HELLO COME PLAY MY GAME");
		
	}
	
	private function onLoadedFireTongue()
	{
		trace(_tonguee.get("$HELLO_WORLD", "data"));
	}
}