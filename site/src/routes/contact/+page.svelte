<div class="max-w-screen-xl mx-auto px-4 md:px-8">
	<div class="max-w-lg mx-auto space-y-3 sm:text-center">
		<p class="text-3xl font-semibold sm:text-4xl">Get in touch</p>
	</div>
	<div class="mt-12 max-w-lg mx-auto">
		<form onsubmit="event.preventDefault()" class="space-y-5">
			<div class="flex flex-col items-center gap-y-5 gap-x-6 [&>*]:w-full sm:flex-row">
				<div>
					<label class="font-medium"> First name </label>
					<input
						type="text"
						required
						class="w-full mt-2 px-3 py-2 bg-transparent outline-none border shadow-sm rounded-lg"
					/>
				</div>
				<div>
					<label class="font-medium"> Last name </label>
					<input
						type="text"
						required
						class="w-full mt-2 px-3 py-2 bg-transparent outline-none border shadow-sm rounded-lg"
					/>
				</div>
			</div>
			<div>
				<label class="font-medium"> Email </label>
				<input
					type="email"
					required
					class="w-full mt-2 px-3 py-2 bg-transparent outline-none border shadow-sm rounded-lg"
				/>
			</div>
			<div>
				<label class="font-medium"> Phone number (optional) </label>
                <input
                type="tel"
                placeholder="+1 234-567-8901"
                pattern="\+?([0-9]{1}[- ])?[0-9]{3}[- ][0-9]{3}[- ][0-9]{4}"
                class="w-full mt-2 px-3 py-2 bg-transparent outline-none border shadow-sm rounded-lg"
            />
			</div>
			<div>
				<label class="font-medium"> Message </label>
				<textarea
					required
					class="w-full mt-2 h-36 px-3 py-2 resize-none appearance-none bg-transparent outline-none border shadow-sm rounded-lg"
				></textarea>
			</div>
			<button class="w-full px-4 py-2 text-white font-medium rounded-lg duration-150">
				Submit
			</button>
		</form>
	</div>
</div>
