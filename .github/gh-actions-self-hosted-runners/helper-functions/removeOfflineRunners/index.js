import functions from '@google-cloud/functions-framework';
import { Octokit } from "octokit";
import { createAppAuth } from "@octokit/auth-app";


async function removeOfflineRunners() {
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

        let runners = await octokit.request(`GET /orgs/${process.env.ORG}/actions/runners`, {
            org: process.env.ORG
        });




        //Filtering BEAM runners
        let beamRunners = runners.data.runners.filter(runner => {
            for (let label of runner.labels) {
                if (label.name == "Linux") {
                    return true;
                }
            }
            return false;

        });

        let offlineRunners = beamRunners.filter(runner => {
            return runner.status == "offline";
        })

        for (let runner of offlineRunners) {
            await octokit.request(`DELETE /orgs/${process.env.ORG}/actions/runners/${runner.id}`, {});
        }
        return offlineRunners
    } catch (error) {
        console.error(error);
    }
}


functions.http('removeOfflineRunners', (req, res) => {
    removeOfflineRunners().then((status) => {
        res.status(200).send(status);
    });
});


