import functions from '@google-cloud/functions-framework';
import { Octokit } from "octokit";
import { createAppAuth } from "@octokit/auth-app";


async function getRunnerToken() {
    try {

        let authOptions = {
            appId: process.env.APP_ID,
            privateKey: process.env.PEM_KEY,
            clientId: process.env.CLIENT_ID,
            clientSecret: process.env.CLIENT_NAME,
            installationId: process.env.APP_INSTALLATION_ID
        }

        const octokit = new Octokit({
            authStrategy: createAppAuth,
            auth: authOptions
        });

        let access = await octokit.request(`POST /app/installations/${process.env.APP_INSTALLATION_ID}}/access_tokens`, {
            repositories: [
                'beam'
            ],
            permissions: {
                organization_self_hosted_runners: "write",
            }
        });

        let authToken = access.data.token;
        let auth = " token " + authToken;

        let registrationToken = await octokit.request(`POST https://api.github.com/orgs/${process.env.ORG}/actions/runners/registration-token`, {
            headers: {
                authorization: auth,
            },
        });


        return registrationToken.data;
    } catch (error) {
        console.error(error);
    }
}

functions.http('generateToken', (req, res) => {
    getRunnerToken().then((registrationToken) => {
        res.status(200).send(registrationToken);
    });
});


