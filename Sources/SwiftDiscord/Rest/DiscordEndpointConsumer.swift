// The MIT License (MIT)
// Copyright (c) 2016 Erik Little

// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
// documentation files (the "Software"), to deal in the Software without restriction, including without
// limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
// Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
// Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
// BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
// EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.

import Foundation

/**
    Protocol that declares a type will be a consumer of the Discord REST API.
    All requests through from a consumer should be rate limited.

    This is where a `DiscordClient` gets the methods that interact with the REST API.

    **NOTE**: Callbacks from the default implementations are *NOT* executed on the client's handleQueue. So it is important
    that if you make modifications to the client inside of a callback, you first dispatch back on the handleQueue.
*/
public protocol DiscordEndpointConsumer {
    // MARK: Properties

    /// The rate limiter for this consumer.
    var rateLimiter: DiscordRateLimiter { get }

    // MARK: Channels

    /**
        Adds a pinned message.

        - parameter messageId: The message that is to be pinned's snowflake id
        - parameter on: The channel that we are adding on
        - parameter callback: An optional callback indicating whether the pinned message was added.
    */
    func addPinnedMessage(_ messageId: MessageID, on channelId: ChannelID, callback: ((Bool) -> ())?)

    /**
        Deletes a bunch of messages at once.

        - parameter messages: An array of message snowflake ids that are to be deleted
        - parameter on: The channel that we are deleting on
        - parameter callback: An optional callback indicating whether the messages were deleted.
    */
    func bulkDeleteMessages(_ messages: [MessageID], on channelId: ChannelID, callback: ((Bool) -> ())?)

    /**
        Creates an invite for a channel/guild.

        - parameter for: The channel that we are creating for.
        - parameter options: An array of `DiscordEndpointOptions.CreateInvite` options.
        - parameter reason: The reason this invite was created.
        - parameter callback: The callback function. Takes an optional `DiscordInvite`
    */
    func createInvite(for channelId: ChannelID,
                      options: [DiscordEndpoint.Options.CreateInvite],
                      reason: String?,
                      callback: @escaping (DiscordInvite?) -> ())

    /**
        Deletes the specified channel.

        - parameter channelId: The snowflake id of the channel.
        - parameter reason: The reason this channel is being deleted.
        - parameter callback: An optional callback indicating whether the channel was deleted.
    */
    func deleteChannel(_ channelId: ChannelID,
                       reason: String?,
                       callback: ((Bool) -> ())?)

    /**
        Deletes a channel permission

        - parameter overwriteId: The permission overwrite that is to be deleted's snowflake id.
        - parameter on: The channel that we are deleting on.
        - parameter reason: The reason this overwrite was deleted.
        - parameter callback: An optional callback indicating whether the permission was deleted.
    */
    func deleteChannelPermission(_ overwriteId: OverwriteID,
                                 on channelId: ChannelID,
                                 reason: String?,
                                 callback: ((Bool) -> ())?)

    /**
        Deletes a single message

        - parameter messageId: The message that is to be deleted's snowflake id
        - parameter on: The channel that we are deleting on
        - parameter callback: An optional callback indicating whether the message was deleted.
    */
    func deleteMessage(_ messageId: MessageID, on channelId: ChannelID, callback: ((Bool) -> ())?)

    /**
        Unpins a message.

        - parameter messageId: The message that is to be unpinned's snowflake id
        - parameter on: The channel that we are unpinning on
        - parameter callback: An optional callback indicating whether the message was unpinned.
    */
    func deletePinnedMessage(_ messageId: MessageID, on channelId: ChannelID, callback: ((Bool) -> ())?)

    /**
        Gets the specified channel.

        - parameter channelId: The snowflake id of the channel
        - parameter callback: The callback function containing an optional `DiscordChannel`
    */
    func getChannel(_ channelId: ChannelID, callback: @escaping (DiscordChannel?) -> ())

    /**
        Edits a message

        - parameter messageId: The message that is to be edited's snowflake id
        - parameter on: The channel that we are editing on
        - parameter content: The new content of the message
        - parameter callback: An optional callback containing the edited message, if successful.
    */
    func editMessage(_ messageId: MessageID, on channelId: ChannelID, content: String, callback: ((DiscordMessage?) -> ())?)

    /**
        Edits the specified permission overwrite.

        - parameter permissionOverwrite: The new DiscordPermissionOverwrite.
        - parameter on: The channel that we are editing on.
        - parameter reason: The reason this edit was made.
        - parameter callback: An optional callback indicating whether the edit was successful.
    */
    func editChannelPermission(_ permissionOverwrite: DiscordPermissionOverwrite,
                               on channelId: ChannelID,
                               reason: String?,
                               callback: ((Bool) -> ())?)

    /**
        Gets the invites for a channel.

        - parameter for: The channel that we are getting on
        - parameter callback: The callback function, taking an array of `DiscordInvite`
    */
    func getInvites(for channelId: ChannelID, callback: @escaping ([DiscordInvite]) -> ())

    /**
        Gets a group of messages according to the specified options.

        - parameter for: The channel that we are getting on
        - parameter options: An array of `DiscordEndpointOptions.GetMessage` options
        - parameter callback: The callback function, taking an array of `DiscordMessages`
    */
    func getMessages(for channel: ChannelID, options: [DiscordEndpoint.Options.GetMessage],
                     callback: @escaping ([DiscordMessage]) -> ())

    /**
        Modifies the specified channel.

        - parameter channelId: The snowflake id of the channel.
        - parameter options: An array of `DiscordEndpointOptions.ModifyChannel` options.
        - parameter reason: The reason this modification is being made.
        - parameter callback: An optional callback containing the edited guild channel, if successful.
    */
    func modifyChannel(_ channelId: ChannelID,
                       options: [DiscordEndpoint.Options.ModifyChannel],
                       reason: String?,
                       callback: ((DiscordGuildChannel?) -> ())?)

    /**
        Gets the pinned messages for a channel.

        - parameter for: The channel that we are getting the pinned messages for
        - parameter callback: The callback function, taking an array of `DiscordMessages`
    */
    func getPinnedMessages(for channelId: ChannelID, callback: @escaping ([DiscordMessage]) -> ())

    /**
        Sends a message with an optional file and embed to the specified channel.

        Sending just a message:

        ```swift
        client.sendMessage("This is a DiscordMessage", to: channelId, callback: nil)
        ```

        Sending a message with an embed:

        ```swift
        client.sendMessage(DiscordMessage(content: "This message also comes with an embed", embeds: [embed]),
                           to: channelId, callback: nil)
        ```

        Sending a fully loaded message:

         ```swift
        client.sendMessage(DiscordMessage(content: "This message has it all", embeds: [embed],
                                          files: [file]),
                           to: channelId, callback: nil)
        ```

        - parameter message: The message to send.
        - parameter to: The snowflake id of the channel to send to.
        - parameter callback: An optional callback containing the message, if successful.
    */
    func sendMessage(_ message: DiscordMessage, to channelId: ChannelID, callback: ((DiscordMessage?) -> ())?)

    /**
        Triggers typing on the specified channel.

        - parameter on: The snowflake id of the channel to send to
        - parameter callback: An optional callback indicating whether typing was triggered.
    */
    func triggerTyping(on channelId: ChannelID, callback: ((Bool) -> ())?)

    // MARK: Guilds

    /**
        Adds a role to a guild member.

        - parameter roleId: The id of the role to add.
        - parameter to: The id of the member to add this role to.
        - parameter on: The id of the guild this member is on.
        - parameter reason: The reason this member is getting this role.
        - parameter callback: An optional callback indicating whether the role was added successfully.
    */
    func addGuildMemberRole(_ roleId: RoleID,
                            to userId: UserID,
                            on guildId: GuildID,
                            reason: String?,
                            callback: ((Bool) -> ())?)

    /**
        Creates a guild channel.

        - parameter guildId: The snowflake id of the guild.
        - parameter options: An array of `DiscordEndpointOptions.GuildCreateChannel` options.
        - parameter reason: The reason this channel is being created.
        - parameter callback: An optional callback containing the new channel, if successful.
    */
    func createGuildChannel(on guildId: GuildID,
                            options: [DiscordEndpoint.Options.GuildCreateChannel],
                            reason: String?,
                            callback: ((DiscordGuildChannel?) -> ())?)

    /**
        Creates a role on a guild.

        - parameter on: The snowflake id of the guild.
        - parameter withOptions: The options for the new role. Optional in the default implementation.
        - parameter reason: The reason this role is being created.
        - parameter callback: The callback function, taking an optional `DiscordRole`.
    */
    func createGuildRole(on guildId: GuildID,
                         withOptions options: [DiscordEndpoint.Options.CreateRole],
                         reason: String?,
                         callback: @escaping (DiscordRole?) -> ())

    /**
        Deletes the specified guild.

        - parameter guildId: The snowflake id of the guild
        - parameter callback: An optional callback containing the deleted guild, if successful.
    */
    func deleteGuild(_ guildId: GuildID, callback: ((DiscordGuild?) -> ())?)

    /**
        Gets a guild's audit log.

        - parameter guildId: The snowflake id of the guild.
        - parameter options: Options for getting the audit log.
        - parameter callback: A callback with the audit log.
    */
    func getGuildAuditLog(for guildId: GuildID, withOptions options: [DiscordEndpoint.Options.AuditLog],
                          callback: @escaping (DiscordAuditLog?) -> ())

    /**
        Gets the bans on a guild.

        - parameter for: The snowflake id of the guild
        - parameter callback: The callback function, taking an array of `DiscordBan`
    */
    func getGuildBans(for guildId: GuildID, callback: @escaping ([DiscordBan]) -> ())

    /**
        Gets the channels on a guild.

        - parameter guildId: The snowflake id of the guild
        - parameter callback: The callback function, taking an array of `DiscordGuildChannel`
    */
    func getGuildChannels(_ guildId: GuildID, callback: @escaping ([DiscordGuildChannel]) -> ())

    /**
        Gets the specified guild member.

        - parameter by: The snowflake id of the member
        - parameter on: The snowflake id of the guild
        - parameter callback: The callback function containing an optional `DiscordGuildMember`
    */
    func getGuildMember(by id: UserID, on guildId: GuildID, callback: @escaping (DiscordGuildMember?) -> ())

    /**
        Gets the members on a guild.

        - parameter on: The snowflake id of the guild
        - parameter options: An array of `DiscordEndpointOptions.GuildGetMembers` options
        - parameter callback: The callback function, taking an array of `DiscordGuildMember`
    */
    func getGuildMembers(on guildId: GuildID, options: [DiscordEndpoint.Options.GuildGetMembers],
                         callback: @escaping ([DiscordGuildMember]) -> ())

    /**
        Gets the roles on a guild.

        - parameter for: The snowflake id of the guild
        - parameter callback: The callback function, taking an array of `DiscordRole`
    */
    func getGuildRoles(for guildId: GuildID, callback: @escaping ([DiscordRole]) -> ())

    /**
        Creates a guild ban.

        - parameter userId: The snowflake id of the user.
        - parameter on: The snowflake id of the guild.
        - parameter deleteMessageDays: The number of days to delete this user's messages.
        - parameter reason: The reason for this ban.
        - parameter callback: An optional callback indicating whether the ban was successful.
    */
    func guildBan(userId: UserID,
                  on guildId: GuildID,
                  deleteMessageDays: Int,
                  reason: String?,
                  callback: ((Bool) -> ())?)

    /**
        Modifies the specified guild.

        - parameter guildId: The snowflake id of the guild.
        - parameter options: An array of `DiscordEndpointOptions.ModifyGuild` options.
        - parameter reason: The reason for this modification.
        - parameter callback: An optional callback containing the modified guild, if successful.
    */
    func modifyGuild(_ guildId: GuildID,
                     options: [DiscordEndpoint.Options.ModifyGuild],
                     reason: String?,
                     callback: ((DiscordGuild?) -> ())?)

    /**
        Modifies the position of a channel.

        - parameter on: The snowflake id of the guild
        - parameter channelPositions: An array of channels that should be reordered. Should contain a dictionary
                                      in the form `["id": channelId, "position": position]`
        - parameter callback: An optional callback containing the modified channels, if successful.
    */
    func modifyGuildChannelPositions(on guildId: GuildID,
                                     channelPositions: [[String: Any]],
                                     callback: (([DiscordGuildChannel]) -> ())?)

    /**
        Modifies a guild member.

        - parameter id: The snowflake id of the member.
        - parameter on: The snowflake id of the member to modify.
        - parameter options: The options for this member.
        - parameter reason: The reason for this change.
        - parameter callback: The callback function, indicating whether the modify succeeded.
    */
    func modifyGuildMember(_ id: UserID,
                           on guildId: GuildID,
                           options: [DiscordEndpoint.Options.ModifyMember],
                           reason: String?,
                           callback: ((Bool) -> ())?)

    /**
        Edits the specified role.

        - parameter permissionOverwrite: The new DiscordRole.
        - parameter on: The guild that we are editing on.
        - parameter reason: The reason for this edit.
        - parameter callback: An optional callback containing the modified role, if successful.
    */
    func modifyGuildRole(_ role: DiscordRole,
                         on guildId: GuildID,
                         reason: String?,
                         callback: ((DiscordRole?) -> ())?)

    /**
        Removes a guild ban.

        - parameter for: The snowflake id of the user.
        - parameter on: The snowflake id of the guild.
        - parameter reason: The reason for this unban.
        - parameter callback: An optional callback indicating whether the ban was successfully removed.
    */
    func removeGuildBan(for userId: UserID,
                        on guildId: GuildID,
                        reason: String?,
                        callback: ((Bool) -> ())?)

    /**
        Removes a role from a guild member.

        - parameter roleId: The id of the role to add.
        - parameter from: The id of the member to add this role to.
        - parameter on: The id of the guild this member is on.
        - parameter reason: The reason for removing this role.
        - parameter callback: An optional callback indicating whether the role was removed successfully.
    */
    func removeGuildMemberRole(_ roleId: RoleID,
                               from userId: UserID,
                               on guildId: GuildID,
                               reason: String?,
                               callback: ((Bool) -> ())?)

    /**
        Removes a guild role.

        - parameter roleId: The snowflake id of the role.
        - parameter on: The snowflake id of the guild.
        - parameter reason: The reason for removing this role.
        - parameter callback: An optional callback containing the removed role, if successful.
    */
    func removeGuildRole(_ roleId: RoleID,
                         on guildId: GuildID,
                         reason: String?,
                         callback: ((DiscordRole?) -> ())?)

    // MARK: Webhooks

    /**
        Creates a webhook for a given channel.

        - parameter forChannel: The channel to create the webhook for.
        - parameter options: The options for this webhook.
        - parameter reason: The reason this webhook was created.
        - parameter callback: A callback that returns the webhook created, if successful.
    */
    func createWebhook(forChannel channelId: ChannelID,
                       options: [DiscordEndpoint.Options.WebhookOption],
                       reason: String?,
                       callback: @escaping (DiscordWebhook?) -> ())

    /**
        Deletes a webhook. The user must be the owner of the webhook.

        - parameter webhookId: The id of the webhook.
        - parameter reason: The reason for deleting this webhook.
        - paramter callback: An optional callback function that indicates whether the delete was successful.
    */
    func deleteWebhook(_ webhookId: WebhookID,
                       reason: String?,
                       callback: ((Bool) -> ())?)

    /**
        Gets the specified webhook.

        - parameter webhookId: The snowflake id of the webhook.
        - parameter callback: The callback function containing an optional `DiscordToken`.
    */
    func getWebhook(_ webhookId: WebhookID,
                    callback: @escaping (DiscordWebhook?) -> ())

    /**
        Gets the webhooks for a specified channel.

        - parameter forChannel: The snowflake id of the channel.
        - parameter callback: The callback function taking an array of `DiscordWebhook`s
    */
    func getWebhooks(forChannel channelId: ChannelID, callback: @escaping ([DiscordWebhook]) -> ())

    /**
        Gets the webhooks for a specified guild.

        - parameter forGuild: The snowflake id of the guild.
        - parameter callback: The callback function taking an array of `DiscordWebhook`s
    */
    func getWebhooks(forGuild guildId: GuildID, callback: @escaping ([DiscordWebhook]) -> ())

    /**
        Modifies a webhook.

        - parameter webhookId: The webhook to modify.
        - parameter options: The options for this webhook.
        - parameter reason: The reason for this modification.
        - parameter callback: A callback that returns the updated webhook, if successful.
    */
    func modifyWebhook(_ webhookId: WebhookID,
                       options: [DiscordEndpoint.Options.WebhookOption],
                       reason: String?,
                       callback: @escaping (DiscordWebhook?) -> ())

    // MARK: Invites

    /**
        Accepts an invite.

        - parameter invite: The invite code to accept
        - parameter callback: An optional callback containing the accepted invite, if successful
    */
    func acceptInvite(_ invite: String, callback: ((DiscordInvite?) -> ())?)

    /**
        Deletes an invite.

        - parameter invite: The invite code to delete.
        - parameter reason: The reason this invite was deleted.
        - parameter callback: An optional callback containing the deleted invite, if successful.
    */
    func deleteInvite(_ invite: String,
                      reason: String?,
                      callback: ((DiscordInvite?) -> ())?)

    /**
        Gets an invite.

        - parameter invite: The invite code to accept
        - parameter callback: The callback function, takes an optional `DiscordInvite`
    */
    func getInvite(_ invite: String, callback: @escaping (DiscordInvite?) -> ())

    // MARK: Users

    /**
        Creates a direct message channel with a user.

        - parameter with: The user that the channel will be opened with's snowflake id
        - parameter user: Our snowflake id
        - parameter callback: The callback function. Takes an optional `DiscordDMChannel`
    */
    func createDM(with: UserID, callback: @escaping (DiscordDMChannel?) -> ())

    /**
        Gets the direct message channels for a user.

        - parameter user: Our snowflake id
        - parameter callback: The callback function, taking a dictionary of `DiscordDMChannel` associated by
                              the recipient's id
    */
    func getDMs(callback: @escaping ([ChannelID: DiscordDMChannel]) -> ())

    /**
        Gets guilds the user is in.

        - parameter user: Our snowflake id
        - parameter callback: The callback function, taking a dictionary of `DiscordUserGuild` associated by guild id
    */
    func getGuilds(callback: @escaping ([ChannelID: DiscordUserGuild]) -> ())

    // MARK: Misc

    /**
        Creates a url that can be used to authorize a bot.

        - parameter with: An array of `DiscordPermission` that this bot should have
    */
    func getBotURL(with permissions: DiscordPermission) -> URL?
}

public extension DiscordEndpointConsumer where Self: DiscordUserActor {
    /// Default implementation
    public func getBotURL(with permissions: DiscordPermission) -> URL? {
        guard let user = self.user else { return nil }

        return DiscordOAuthEndpoint.createBotAddURL(for: user, with: permissions)
    }
}
