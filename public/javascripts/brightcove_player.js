var brightcovePlayer = {
  "params": {
    playerID:"641807589001",
    publishedID:"105925308001",
    bgcolor:"#ffffff",
    width:"566",
    height:"318",
    isVid:"true",
    isUI:"true",
    videoId:"0",
    playerKey:"AQ%2E%2E,AAAAGKmj7mE%2E,mo4U6jieCmBlzspTCceSHSMrjk4_eTc6",
		wmode: "transparent"
  },
  startPlayer:function(){
    isPlayerAdded = true;
    playerName = "player1";
    var player = brightcove.createElement("object");
    player.id = playerName;
    var parameter;
    for (var i in this.params) {
      parameter = brightcove.createElement("param");
      parameter.name = i;
      parameter.value = this.params[i];
      player.appendChild(parameter);
    }

    var playerContainer = document.getElementById("x_video_player");

    brightcove.createExperience(player, playerContainer, true);
  }
}
