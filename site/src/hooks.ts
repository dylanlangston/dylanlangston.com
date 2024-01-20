//import { redirect, type MaybePromise, type RequestEvent, type ResolveOptions, type Reroute } from '@sveltejs/kit';

// export async function handle(input: 
//     { 
//         event: RequestEvent, 
//         resolve: (event: RequestEvent, opts?: ResolveOptions) => MaybePromise<Response> 
//     }) {
// 	if (input.event.url.pathname.match(/[A-Z]/)) {
// 		throw redirect(307, input.event.url.pathname.toLowerCase());
// 	}

// 	const response = await input.resolve(input.event);

// 	return response;
// }

// import type { Handle } from '@sveltejs/kit';

// export const handle = (async ({ event, resolve }) => {
//   if (event.url.pathname.startsWith('/custom')) {
//     return new Response('custom response');
//   }

//   const response = await resolve(event);
//   return response;
// }) satisfies Handle;

import type { Reroute } from '@sveltejs/kit';

export const reroute: Reroute = ({ url }) => {
	// Make paths case insensive by setting to lowercase
	return url.pathname.toLowerCase();
};