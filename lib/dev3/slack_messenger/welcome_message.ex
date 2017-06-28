defmodule Dev3.SlackMessenger.HTTPClient.WelcomeMessage do
  @moduledoc false

  @behaviour Dev3.SlackMessenger.HTTPClient

  def build_message(_data) do
    %{text: build_text(), attachments: build_attachments()}
  end

  defp build_text do
    """
    :wave: Welcome to your private channel with *GitBruh* ! All messages sent
    by GitBruh will go here. These are some leads to get you started :
    """
  end
  defp build_attachments do
    [%{
      title: ":hammer_and_wrench: Beta version",
      mrkdwn_in: ["text"],
      text: """
        GitBruh is still in its early days.
        Don't hesitate to open an issue if an idea comes up, something weird happens, or simply to ask a question !

        :warning: A cleanup of all data might occur at the end of the beta phase, all user accounts,\
        watched repos, and other user info *will be lost*. Sorry for the inconvenience.
      """,
      color: "#ff0000"
    },
    %{
      title: ":eye: Watch a GitHub repo",
      mrkdwn_in: ["text"],
      text: """

        Example : `/watchrepos John/awesome-stuff`
        Two things are happening here :
        · GitBruh registers the repo as being watched by you.
        · GitBruh adds a GitHub webhook to the repo.

        The response confirms that everything went well or gives you more details\
        on further actions you might need to take in order to properly set up your repo for GitBruh.

        You can unwatch a repo by issuing `/unwatchrepos`. This action won't delete the webhook.
       """,
      color: "#00487c"
    },
    %{
      title: ":books: Going further",
      mrkdwn_in: ["text"],
      text: """
        To learn more, you can check Gitbruh's <https://bachirc.github.io/Drop-Everything-v3-web|documentation>. The following\
        topics can give you a better understanding of GitBruh's functionalities :
        · <https://bachirc.github.io/Drop-Everything-v3-web/index.html#Messages-list|List of messages sent by GitBruh>
        · <https://bachirc.github.io/Drop-Everything-v3-web/index.html#Messages-list|How to interact with messages>
        · <https://bachirc.github.io/Drop-Everything-v3-web/index.html#Slack-commands|Slack commands full description>

        Found a bug ? <https://github.com/BachirC/Drop-Everything-v3/issues|Open an issue> on GitHub :)

        Willing to contribute to <https://github.com/BachirC/Drop-Everything-v3|GitBruh> ?\
        Feel free to send a pull request, the project is open source !
      """,
      color: "#66bfff"
      }]
  end
end
