import functions from '@google-cloud/functions-framework';
import { Octokit } from "octokit";
import { createAppAuth } from "@octokit/auth-app";

async function monitorRunnerStatus() {
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

        let runners = await octokit.request(`GET /orgs/${process.env.ORG}/actions/runners`, {
            org: process.env.ORG
        });




        //Filtering BEAM runners
        let beamRunners = runners.data.runners.filter(runner => {
            for (let label of runner.labels) {
                if (label.name == "beam") {
                    return true;
                }
            }
            return false;

        });

        //Dividing status for each runner OS    
        let osList = ["Linux", "Windows"];
        let status = {}
        for (let os of osList) {
            let osRunners = beamRunners.filter(runner => {
                for (let label of runner.labels) {
                    if (label.name == os) {
                        return true;
                    }
                }
                return false;
            });

            let onlineRunners = osRunners.filter(runner => {
                return runner.status == "online";
            });

            status[os] = {
                "totalRunners": osRunners.length,
                "onlineRunners": onlineRunners.length,
                "offlineRunners": osRunners.length - onlineRunners.length
            }

        }

        return status;
    } catch (error) {
        console.error(error);
    }
}

functions.http('monitorRunnerStatus', (req, res) => {

    monitorRunnerStatus().then((status) => {
        res.status(200).send(status);
    });

});


