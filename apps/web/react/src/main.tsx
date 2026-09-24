import React from 'react';
import ReactDOM from 'react-dom/client';

import { Application } from '../../Application';
import { App } from './app/App';

const application = new Application();

console.log(application.configurationService.getApiBaseUrl());

ReactDOM.createRoot(document.getElementById('root')!).render(
    <React.StrictMode>
        <App />
    </React.StrictMode>,
);

// import React from 'react';
// import ReactDOM from 'react-dom/client';
// import { FrontendConfigurationService } from '../../FrontendConfigurationService';
// import { RuntimeConfigurationProvider } from '../../RuntimeConfigurationProvider';
// import { App } from './app/App';
// import { Application } from './Application';
// import { loadApplicationConfiguration } from './loadApplicationConfiguration';

// export const application = new Application(loadApplicationConfiguration());

// const runtimeConfigurationProvider = new RuntimeConfigurationProvider();
// export const frontendConfigurationService = new FrontendConfigurationService(
//     runtimeConfigurationProvider.getConfiguration(),
// );

// ReactDOM.createRoot(
//     document.getElementById('root')!
// ).render(
//     <React.StrictMode>
//         <App />
//     </React.StrictMode>
// );

// // import React from 'react';
// // import ReactDOM from 'react-dom/client';
// // import { App } from './app/App';
// // import { Application } from './Application';
// // import { loadApplicationConfiguration } from './loadApplicationConfiguration';

// // export const application = new Application(loadApplicationConfiguration());

// // ReactDOM.createRoot(
// //     document.getElementById('root')!
// // ).render(
// //     <React.StrictMode>
// //         <App />
// //     </React.StrictMode>
// // );

// // // import React from 'react';
// // // import ReactDOM from 'react-dom/client';
// // // import { RouterProvider } from 'react-router-dom';
// // // import { router } from './app/router';

// // // ReactDOM.createRoot(
// // //     document.getElementById('root')!
// // // ).render(
// // //     <RouterProvider router={router} />
// // // );

// // // import React from 'react';
// // // import ReactDOM from 'react-dom/client';
// // // import { App } from './app/App';
// // // import { loadApplicationConfiguration } from './loadApplicationConfiguration';

// // // export const applicationConfiguration =
// // //     loadApplicationConfiguration();

// // // ReactDOM.createRoot(
// // //     document.getElementById(
// // //         'root',
// // //     )!,
// // // ).render(
// // //     <React.StrictMode>
// // //         <App />
// // //     </React.StrictMode>,
// // // );

// // // // import React from 'react';
// // // // import ReactDOM from 'react-dom/client';
// // // // import { Application } from '../../Application';
// // // // import { FrontendConfigurationService } from '../../FrontendConfigurationService';
// // // // import { App } from './app/App';

// // // // const application = new Application(new FrontendConfigurationService());

// // // // await application.initialize();

// // // // ReactDOM.createRoot(document.getElementById('root')!).render(
// // // //     <React.StrictMode>
// // // //         <App />
// // // //     </React.StrictMode>,
// // // // );

// // // // // import React from 'react';
// // // // // import ReactDOM from 'react-dom/client';
// // // // // import { Application } from '../../Application';
// // // // // import { App } from './app/App';

// // // // // import { FrontendConfigurationService } from '../../FrontendConfigurationService';

// // // // // const application = new Application(new FrontendConfigurationService());

// // // // // await application.initialize();

// // // // // ReactDOM.createRoot(document.getElementById('root')!).render(
// // // // //     <React.StrictMode>
// // // // //         <App />
// // // // //     </React.StrictMode>,
// // // // // );

// // // // // // import React from 'react';

// // // // // // import ReactDOM from 'react-dom/client';

// // // // // // import { App } from './app/App';

// // // // // // ReactDOM.createRoot(document.getElementById('root')!).render(
// // // // // //     <React.StrictMode>
// // // // // //         <App />
// // // // // //     </React.StrictMode>,
// // // // // // );
