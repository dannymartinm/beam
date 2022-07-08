import functions from '@google-cloud/functions-framework';
import { Octokit } from "octokit";
import { createAppAuth } from "@octokit/auth-app";


async function getRunnerToken() {
    try {

        let authOptions = {
            appId: process.env.APP_SECRET,
            privateKey: process.env.PEM_SECRET,
            clientId: process.env.CLIENT_ID_SECRET,
            clientSecret: process.env.CLIENT_SECRET,
            installationId: process.env.APP_INSTALLATION_SECRET
        }

        const octokit = new Octokit({
            authStrategy: createAppAuth,
            auth: authOptions
        });

        let access = await octokit.request(`POST /app/installations/${process.env.APP_INSTALLATION_SECRET}}/access_tokens`, {
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


