<script lang="ts">
	/**
	 * Defines the classic Material Design ripple effect as an action. `ripple` is a wrapper around the returned action.
	 * This allows it to be easily used as a prop.
	 *
	 * @param {object}   opts - Optional parameters.
	 *
	 * @param {number}   opts.duration - Duration in milliseconds.
	 *
	 * @param {string}   opts.color - A valid CSS color.
	 *
	 * @returns Function - Actual action.
	 */
	function Ripple({ duration = 500, color = 'rgba(255, 255, 255, 0.7)' } = {}) {
		return (element: HTMLElement) => {
			function createRipple(e: MouseEvent) {
				const elementRect = element.getBoundingClientRect();

				const diameter = (escapeParent || fullscreen) ? Math.max(window.innerWidth, window.innerHeight) : Math.max(elementRect.width, elementRect.height);

				const radius = diameter / 2;
				const left = `${e.x - radius}px`;
				const top = `${e.y - radius}px`;

				const span = document.createElement('span');
				span.style.width = `${diameter}px`;
				span.style.height = `${diameter}px`;
				span.style.left = left;
				span.style.top = top;
				span.style.position = 'absolute';
				span.style.borderRadius = '50%';
				span.style.backgroundColor = `var(--color-effect-ripple, ${color})`;

                let div: HTMLDivElement | undefined = undefined;
                if (escapeParent) {
                    parentElement?.append(span);
                }
                else if (fullscreen) {
                    div = document.createElement('div');
                    div.classList.add(
                        'overflow-hidden', 
                        'absolute', 
                        'top-0', 
                        'left-0', 
                        'right-0', 
                        fullscreen ? 'w-lvw' : '', 
                        fullscreen ? 'h-lvh' : '', 
                        'bottom-0', 
                        'z-50', 
                        'pointer-events-none'
                    );
                    div.append(span);
                    document.body.append(div);
                }
                else {
                    element.append(span);
                }

				const animation = span.animate(
					[
						{
							// from
							transform: 'scale(.7)',
							opacity: 0.5,
							filter: 'blur(2px) saturate(1)'
						},
						{
							// to
							transform: 'scale(4)',
							opacity: 0,
							filter: 'blur(5px) saturate(4)'
						}
					],
					duration
				);

				animation.onfinish = () => div?.remove() ?? span.remove();
			}

			element.addEventListener('click', createRipple);

			return {
				destroy() {
					element.removeEventListener('click', createRipple);
				}
			};
		};
	}

    let parentElement: HTMLDivElement | undefined = undefined;

    export let escapeParent: boolean = false;
    export let fullscreen: boolean = false;

    export let classList: string = '';

    export let color: string = 'var(--Rainbow)';

	const ripple = Ripple({ color: color });
</script>

<div class="{escapeParent ? '' : 'rounded-lg relative overflow-hidden'}">
	<div class="{classList}" use:ripple>
		<slot />
	</div>
</div>
{#if escapeParent}
    <div class="overflow-hidden absolute top-0 left-0 right-0 bottom-0 z-50 pointer-events-none" bind:this={parentElement}></div>
{/if}