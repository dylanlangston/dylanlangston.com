<style>
.loader {
  color: var(--Rainbow);
  filter: hue-rotate(180deg) drop-shadow(0px 0px 3vh black);
  width: 6px;
  aspect-ratio: 1;
  border-radius: 50%; 
  animation:
    box-animation 1s infinite linear alternate,
    rotate-animation 2s infinite linear; 
}
@keyframes box-animation {
  0%,
  20% {box-shadow:10vw 0 0 2vw, 3.5vw 0 0 2vw, -3.5vw 0 0 2vw,-10vw 0 0 2vw}
  60%,
  100% {box-shadow:5vw 0 0 2vw, 5vw 0 0 2vw, -5vw 0 0 2vw,-5vw 0 0 2vw}
}

@keyframes rotate-animation {
  0%,25%   {transform: rotate(0)}
  50%,100% {transform: rotate(.5turn)}
}
</style>

<div class="loader"></div>