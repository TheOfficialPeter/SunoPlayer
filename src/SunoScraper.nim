import dimscord, asyncdispatch, strutils, options
import dotenv, std/os
import std/json
import std/httpclient
import tables

# Load environment variables from .env file
load()

# Load discord bot object
let discord = newDiscordClient(getEnv("DISCORD_TOKEN"))

# --- HTTP
proc makeHttpRequest(url: string): JsonNode =
  var client = newHttpClient()
  var response = client.getContent(url)
  return parseJson(response)

# --- SunoScraper

type
  SunoSong = object
    title: string
    artist: string
    album: string
    year: int
    genre: string
    duration: int
    lyrics: string
    url: string

proc searchSunoSong(songTitle: string): SunoSong =
  # Implement the search logic using HttpClient
  var song = SunoSong(title: "Song Title", artist: "Artist Name", album: "Album Name", year: 2021, genre: "Genre", duration: 180, lyrics: "Lyrics", url: "https://example.com")
  return song

proc createSunoPlaylist(songs: seq[SunoSong]): string =
  # Create new playlist on Suno using HttpClient
  return "Playlist created"

# --- Discord

proc onReady(s: Shard, r: Ready) {.event(discord).} =
  discard await discord.api.bulOverwriteApplicationCommands(
    s.user.id,
    @[
      ApplicationCommand(
        name: "search",
        kind: atUser,
      )
    ],
    guild_id = "YOUR_GUILD_ID"
  )

proc interactionCreate(s: Shard, i: Interaction) {.event(discord).} =
  let data = i.data.get
  var msg = ""
  if data.kind == atUser:
    for user in data.resolved.users.values:
      msg &= "You have high fived " & user.username & "\n"
  elif data.kind == atMessage:
    for message in data.resolved.messages.values:
      msg &= message.content & "\n"

  await discord.api.interactionResponseMessage(i.id, i.token,
    kind = irtChannelMessageWithSource,
    response = InteractionCallbackDataMessage(content = msg))

waitFor discord.startSession()

