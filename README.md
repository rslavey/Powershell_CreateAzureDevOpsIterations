Creating a New Release Iteration (with Sprints!) Using Powershell
=================================================================

> “Always choose a lazy person to do a difficult job because a lazy person will find an easy way to do it.”

If you’ve stumbled upon this repo, you’re probably searching for a quick and easy way to bulk create iterations in Azure DevOps. You’re probably also thinking, “Hey, DevOps has an API. I’m sure I can do it through there.” You may have even stumbled upon [Donovan Brown’s article](https://www.donovanbrown.com/post/how-to-call-team-services-rest-api-from-powershell). If you did, you probably ran into the same problem I did; there are (currently) no API calls for admin functions such as adding iterations to a project.

> “…sorry for the confusion, this api is not meant to create a iteration, but to subscribe an existing iteration to your team…”
> 
> [https://developercommunity.visualstudio.com/content/problem/649601/azure-devops-rest-api-post-for-iterations-returns.html](https://developercommunity.visualstudio.com/content/problem/649601/azure-devops-rest-api-post-for-iterations-returns.html)

Once they are added to the project, you can assign them to a team via the API, but first you have to go through the tedious process of Add Child > Name, Start Date, Finish Date.

_Warning: This is not a supported Microsoft API and can change at any time._

First, grab the code from the repo here.

Second, you will need a user token. As a user with rights to create iterations in a project, go to Azure DevOps > User Settings > Personal Access Tokens, and create a new token titled something like “Iteration PowerShell”. Set the expiration to whatever length you’re comfortable with.

Next, you’ll need your Azure DevOps project’s GUID. From a web browser, go to:

    https://dev.azure.com/[YOUR_TENANT]/_apis/projects?api-version=5.1

This will return a list of your projects. Find the appropriate project and copy the project id.

Finally, you’ll need the GUID of the root project iteration. This is a little more complicated as it’s not readily available via the API (see previous complaint about lack of admin API calls). To get the GUID, fire up Fiddler and start capturing. Go to your Azure DevOps project configuration settings and edit the root item (you can immediately cancel the edit). Now, in Fiddler results, find the URL “/\_apis/Contribution/dataProviders/query”. In the JSON, you will find the property “nodeId”. This is your root iteration GUID.

![image](https://user-images.githubusercontent.com/21177142/135322614-8ce25b10-470b-41e0-861d-4a8ca52cc4c7.png)

![Screenshot2](https://user-images.githubusercontent.com/21177142/135323220-110a4c16-bfc4-4d3c-93d5-ee58928cb631.png)

That’s it. Enter the token and project ID in the Powershell, set the other values as appropriate, and run it.

    $pat = "YOUR PERSONAL ACCESS TOKEN"
    $parentId = "ROOT ITERATION GUID"
    $projectId = "PROJECT GUID"

![image](https://user-images.githubusercontent.com/21177142/135322704-8cffbf1c-a617-424f-b5c1-f12d570fd297.png)
