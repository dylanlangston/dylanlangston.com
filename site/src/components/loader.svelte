<div class="loader" ></div>

<style>
	.loader {
		color: var(--Rainbow);
		filter: hue-rotate(180deg) drop-shadow(0px 0px 3vh black);
		width: 6px;
		aspect-ratio: 1;
		border-radius: 50%;
		animation:
			box-animation 1s infinite linear alternate,
			rotate-animation 2s infinite ease,
			shadow-animation 3s infinite alternate,
      fade-in 2s;
	}
	@keyframes box-animation {
		0%,
		20% {
			box-shadow:
				10vw 0 0 2vw,
				3.5vw 0 0 2vw,
				-3.5vw 0 0 2vw,
				-10vw 0 0 2vw;
		}
		60%,
		100% {
			box-shadow:
				5vw 0 0 2vw,
				5vw 0 0 2vw,
				-5vw 0 0 2vw,
				-5vw 0 0 2vw;
		}
	}

	@keyframes rotate-animation {
		0%,
		25% {
			transform: rotate(0);
		}
		50%,
		100% {
			transform: rotate(0.5turn);
		}
	}

	@keyframes shadow-animation {
		0%{
			filter: hue-rotate(180deg) drop-shadow(0px 0px 3vh black);
		}
		50% {
			filter: hue-rotate(180deg) drop-shadow(0px 0px 5vh white);
		}
	}

  @keyframes fade-in {
    0%, 50% { opacity: 0; }
    100%   { opacity: 1; }
  }
</style>
