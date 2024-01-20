// import { redirect, type Handle } from '@sveltejs/kit';

// export const handle: Handle = async ({ event, resolve }) => {
//     // Redirect uppercase to lowercase
//     if (event.url.pathname.match(/[A-Z]/)) {
// 		throw redirect(307, event.url.pathname.toLowerCase());
// 	}


// 	const response = await resolve(event);
// 	return response;
// };